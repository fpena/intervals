//
//  ParentControlsSection.swift
//  Intervals
//

import SwiftUI

struct ParentControlsButton: View {
    @State private var showPINEntry = false
    @State private var showParentControls = false
    @AppStorage("parentPIN") private var storedPIN: String = ""

    var body: some View {
        Section {
            Button {
                if storedPIN.isEmpty {
                    // First time: set up PIN
                    showParentControls = true
                } else {
                    // Require PIN entry
                    showPINEntry = true
                }
            } label: {
                HStack {
                    SettingsRow(
                        icon: "lock.fill",
                        iconColor: .gray,
                        title: "Parent Controls"
                    )
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        }
        .sheet(isPresented: $showPINEntry) {
            PINEntryView(correctPIN: storedPIN) { success in
                if success {
                    showPINEntry = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showParentControls = true
                    }
                }
            }
        }
        .sheet(isPresented: $showParentControls) {
            ParentControlsView()
        }
    }
}

// MARK: - PIN Entry View

struct PINEntryView: View {
    let correctPIN: String
    let onSuccess: (Bool) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var enteredPIN = ""
    @State private var showError = false
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Enter Parent PIN")
                    .font(.title2)
                    .fontWeight(.semibold)

                // PIN dots
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPIN.count ? Color.primary : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                    }
                }
                .shake(showError)

                // Hidden text field for keyboard input
                TextField("", text: $enteredPIN)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .opacity(0)
                    .frame(width: 1, height: 1)
                    .onChange(of: enteredPIN) { _, newValue in
                        // Limit to 4 digits and only numbers
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count > 4 {
                            enteredPIN = String(filtered.prefix(4))
                        } else if filtered != newValue {
                            enteredPIN = filtered
                        }

                        // Check PIN when 4 digits entered
                        if enteredPIN.count == 4 {
                            if enteredPIN == correctPIN {
                                onSuccess(true)
                            } else {
                                withAnimation(.default) {
                                    showError = true
                                }
                                enteredPIN = ""
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showError = false
                                }
                            }
                        }
                    }

                if showError {
                    Text("Incorrect PIN")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                isFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Set PIN View

struct SetPINView: View {
    var currentPIN: String = ""
    let onComplete: (String) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var stage: PINStage = .enterNew
    @State private var showError = false
    @FocusState private var isFocused: Bool

    enum PINStage {
        case enterNew
        case confirm
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text(stage == .enterNew ? "Enter New PIN" : "Confirm PIN")
                    .font(.title2)
                    .fontWeight(.semibold)

                // PIN dots
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        let pin = stage == .enterNew ? newPIN : confirmPIN
                        Circle()
                            .fill(index < pin.count ? Color.primary : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                    }
                }
                .shake(showError)

                // Hidden text field
                TextField("", text: stage == .enterNew ? $newPIN : $confirmPIN)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .opacity(0)
                    .frame(width: 1, height: 1)
                    .onChange(of: newPIN) { _, newValue in
                        handlePINChange(newValue, isNew: true)
                    }
                    .onChange(of: confirmPIN) { _, newValue in
                        handlePINChange(newValue, isNew: false)
                    }

                if showError {
                    Text("PINs don't match. Try again.")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                isFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func handlePINChange(_ value: String, isNew: Bool) {
        let filtered = value.filter { $0.isNumber }
        if isNew {
            if filtered.count > 4 {
                newPIN = String(filtered.prefix(4))
            } else if filtered != value {
                newPIN = filtered
            }

            if newPIN.count == 4 {
                stage = .confirm
                isFocused = true
            }
        } else {
            if filtered.count > 4 {
                confirmPIN = String(filtered.prefix(4))
            } else if filtered != value {
                confirmPIN = filtered
            }

            if confirmPIN.count == 4 {
                if confirmPIN == newPIN {
                    onComplete(newPIN)
                    dismiss()
                } else {
                    withAnimation(.default) {
                        showError = true
                    }
                    confirmPIN = ""
                    newPIN = ""
                    stage = .enterNew
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showError = false
                    }
                }
            }
        }
    }
}

// MARK: - Parent Controls View

struct ParentControlsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("parentPIN") private var storedPIN: String = ""
    @AppStorage("screenTimeLimit") private var screenTimeLimit: Int = 0
    @AppStorage("contentFilterEnabled") private var contentFilterEnabled: Bool = false
    @State private var showChangePIN = false
    @State private var showSetPIN = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Screen Time
                Section("Screen Time") {
                    Picker("Daily Limit", selection: $screenTimeLimit) {
                        Text("Unlimited").tag(0)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                    }

                    if screenTimeLimit > 0 {
                        Text("Practice will pause after \(screenTimeLimit) minutes each day.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Content
                Section("Content") {
                    Toggle("Age-Appropriate Mode", isOn: $contentFilterEnabled)
                        .tint(.appPrimary)

                    Text("When enabled, adjusts difficulty and content based on the child's age.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // PIN Management
                Section("Security") {
                    if storedPIN.isEmpty {
                        Button("Set PIN") {
                            showSetPIN = true
                        }
                    } else {
                        Button("Change PIN") {
                            showChangePIN = true
                        }

                        Button("Remove PIN", role: .destructive) {
                            storedPIN = ""
                        }
                    }
                }

                // Data Management
                Section("Data") {
                    Button("Delete All Data", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Parent Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showSetPIN) {
                SetPINView { newPIN in
                    storedPIN = newPIN
                }
            }
            .sheet(isPresented: $showChangePIN) {
                SetPINView(currentPIN: storedPIN) { newPIN in
                    storedPIN = newPIN
                }
            }
            .alert("Delete All Data?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    // TODO: Clear all SwiftData models
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all profiles and progress. This cannot be undone.")
            }
        }
    }
}

#Preview("Parent Controls Button") {
    List {
        ParentControlsButton()
    }
}

#Preview("PIN Entry") {
    PINEntryView(correctPIN: "1234") { _ in }
}

#Preview("Parent Controls") {
    ParentControlsView()
}
