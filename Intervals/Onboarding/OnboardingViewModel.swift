//
//  OnboardingViewModel.swift
//  Intervals
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Navigation State
    @Published var currentScreen: OnboardingScreen = .flowSelection
    @Published var isComplete: Bool = false

    // MARK: - Collected Data
    @Published var setupFlow: SetupFlow = .child
    @Published var name: String = ""
    @Published var ageGroup: AgeGroup = OnboardingDefaults.ageGroup
    @Published var selectedInstruments: Set<OnboardingInstrument> = []
    @Published var otherInstrumentText: String = ""
    @Published var selectedGrade: ABRSMGrade = .grade1
    @Published var selectedGoal: LearningGoal = OnboardingDefaults.goal
    @Published var reminderEnabled: Bool = false
    @Published var reminderTime: Date = OnboardingDefaults.reminderTime
    @Published var reminderDays: Set<Weekday> = Set(OnboardingDefaults.reminderDays)

    // MARK: - Placement Test State
    @Published var showPlacementTest: Bool = false
    @Published var placementTestScore: Double?

    // MARK: - Validation
    var isNameValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 20 else { return false }
        let allowedCharacters = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: "-'"))
        return trimmed.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    var isInstrumentSelectionValid: Bool {
        !selectedInstruments.isEmpty
    }

    var canProceed: Bool {
        switch currentScreen {
        case .flowSelection:
            return true
        case .welcome:
            return true
        case .nameInput:
            return isNameValid
        case .ageSelection:
            return true
        case .instrumentSelection:
            return isInstrumentSelectionValid
        case .gradeSelection:
            return true
        case .goalSelection:
            return true
        case .reminderSetup:
            return true
        case .completion:
            return true
        }
    }

    // MARK: - Screen Progress

    var progress: Double {
        let current = Double(currentScreen.rawValue)
        let total = Double(OnboardingScreen.totalScreens - 1)
        return current / total
    }

    var screenNumber: Int {
        currentScreen.rawValue
    }

    var totalScreens: Int {
        OnboardingScreen.totalScreens
    }

    // MARK: - Navigation

    func goToNext() {
        guard canProceed else { return }

        // Handle special cases
        if currentScreen == .gradeSelection && selectedGrade == .notSure {
            showPlacementTest = true
            return
        }

        let allScreens = OnboardingScreen.allCases
        if let currentIndex = allScreens.firstIndex(of: currentScreen),
           currentIndex + 1 < allScreens.count {
            currentScreen = allScreens[currentIndex + 1]
        }

        if currentScreen == .completion {
            isComplete = true
        }
    }

    func goBack() {
        let allScreens = OnboardingScreen.allCases
        if let currentIndex = allScreens.firstIndex(of: currentScreen),
           currentIndex > 0 {
            currentScreen = allScreens[currentIndex - 1]
        }
    }

    func skipOnboarding() {
        isComplete = true
    }

    // MARK: - Placement Test

    func completePlacementTest(recommendedGrade: ABRSMGrade, score: Double) {
        selectedGrade = recommendedGrade
        placementTestScore = score
        showPlacementTest = false
        goToNext()
    }

    func cancelPlacementTest() {
        showPlacementTest = false
    }

    // MARK: - Save to User Profile

    func saveToProfile(_ profile: UserProfile, modelContext: ModelContext) {
        profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.ageGroup = ageGroup
        profile.instruments = Array(selectedInstruments)
        profile.primaryInstrument = selectedInstruments.first
        profile.goal = selectedGoal
        profile.setupFlow = setupFlow
        profile.currentGrade = selectedGrade.toGrade
        profile.reminderEnabled = reminderEnabled
        profile.reminderTime = reminderTime
        profile.reminderDays = Array(reminderDays)
        profile.placementTestTaken = placementTestScore != nil
        profile.placementTestScore = placementTestScore
        profile.completeOnboarding()

        try? modelContext.save()
    }

    // MARK: - Flow-specific Text

    func headline(for screen: OnboardingScreen) -> String {
        switch screen {
        case .flowSelection:
            return "Welcome! Who's setting up today?"
        case .welcome:
            return setupFlow.welcomeHeadline
        case .nameInput:
            return setupFlow == .child ? "What's your name?" : "What's your child's name?"
        case .ageSelection:
            let displayName = name.isEmpty ? "" : name
            return setupFlow == .child
                ? "How old are you\(displayName.isEmpty ? "" : ", \(displayName)")?"
                : "How old is \(displayName.isEmpty ? "your child" : displayName)?"
        case .instrumentSelection:
            return setupFlow == .child
                ? "What instrument do you play?"
                : "What instrument does \(name.isEmpty ? "your child" : name) play?"
        case .gradeSelection:
            return "What ABRSM grade are you working on?"
        case .goalSelection:
            return "What brings you here?"
        case .reminderSetup:
            return "Want a daily practice reminder?"
        case .completion:
            return "You're all set, \(name.isEmpty ? OnboardingDefaults.name : name)!"
        }
    }

    func subtext(for screen: OnboardingScreen) -> String {
        switch screen {
        case .flowSelection:
            return ""
        case .welcome:
            return setupFlow.welcomeSubtext
        case .nameInput:
            return ""
        case .ageSelection:
            return ""
        case .instrumentSelection:
            return "Pick all that apply!"
        case .gradeSelection:
            return "Don't worry, you can change this later!"
        case .goalSelection:
            return "This helps us personalize your experience"
        case .reminderSetup:
            return "A little practice every day goes a long way!"
        case .completion:
            return "Let's start training those ears!"
        }
    }

    func ctaText(for screen: OnboardingScreen) -> String {
        switch screen {
        case .flowSelection:
            return "Continue"
        case .welcome:
            return setupFlow.ctaText
        case .nameInput:
            return setupFlow == .child ? "That's me!" : "Continue"
        case .gradeSelection where selectedGrade == .notSure:
            return "Take the placement test"
        case .reminderSetup:
            return reminderEnabled ? "Set reminder" : "Maybe later"
        case .completion:
            return "Start practicing!"
        default:
            return setupFlow.continueText
        }
    }
}
