//
//  ConvexClient.swift
//  Intervals
//
//  Created by Felipe Pena on 2026-01-25.
//

import Foundation
import Combine

/// A client for communicating with the Convex backend
@MainActor
class ConvexClient: ObservableObject {
    static let shared = ConvexClient()

    private let baseURL: URL
    private let session: URLSession

    @Published var isLoading = false
    @Published var error: ConvexError?

    init(deploymentURL: String = ConvexConfig.deploymentURL) {
        guard let url = URL(string: deploymentURL) else {
            fatalError("Invalid Convex deployment URL")
        }
        self.baseURL = url
        self.session = URLSession.shared
    }

    // MARK: - Query Methods

    /// Execute a Convex query
    func query<T: Decodable>(
        _ functionName: String,
        args: [String: Any] = [:]
    ) async throws -> T {
        let url = baseURL.appendingPathComponent("api/query")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "path": functionName,
            "args": args
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ConvexError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ConvexError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            let convexResponse = try JSONDecoder().decode(ConvexQueryResponse<T>.self, from: data)

            if let errorMessage = convexResponse.errorMessage {
                throw ConvexError.queryFailed(message: errorMessage)
            }

            guard let value = convexResponse.value else {
                throw ConvexError.noData
            }

            return value
        } catch let error as ConvexError {
            self.error = error
            throw error
        } catch {
            let convexError = ConvexError.networkError(error)
            self.error = convexError
            throw convexError
        }
    }

    /// Execute a Convex mutation
    func mutation<T: Decodable>(
        _ functionName: String,
        args: [String: Any] = [:]
    ) async throws -> T {
        let url = baseURL.appendingPathComponent("api/mutation")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "path": functionName,
            "args": args
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ConvexError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ConvexError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            let convexResponse = try JSONDecoder().decode(ConvexQueryResponse<T>.self, from: data)

            if let errorMessage = convexResponse.errorMessage {
                throw ConvexError.mutationFailed(message: errorMessage)
            }

            guard let value = convexResponse.value else {
                throw ConvexError.noData
            }

            return value
        } catch let error as ConvexError {
            self.error = error
            throw error
        } catch {
            let convexError = ConvexError.networkError(error)
            self.error = convexError
            throw convexError
        }
    }

    func clearError() {
        error = nil
    }
}

// MARK: - Response Types

struct ConvexQueryResponse<T: Decodable>: Decodable {
    let value: T?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case value
        case errorMessage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decodeIfPresent(T.self, forKey: .value)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
    }
}

// MARK: - Error Types

enum ConvexError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case queryFailed(message: String)
    case mutationFailed(message: String)
    case noData
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .queryFailed(let message):
            return "Query failed: \(message)"
        case .mutationFailed(let message):
            return "Mutation failed: \(message)"
        case .noData:
            return "No data returned from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Configuration

enum ConvexConfig {
    // TODO: Replace with your actual Convex deployment URL
    static let deploymentURL = "https://flexible-curlew-201.convex.cloud"
}
