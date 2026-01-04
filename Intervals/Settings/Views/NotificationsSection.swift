//
//  NotificationsSection.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct NotificationsSection: View {
    @Bindable var user: UserProfile
    @AppStorage("reminderHour") private var reminderHour: Int = 18
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @State private var showPermissionAlert = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 18
                reminderMinute = components.minute ?? 0
            }
        )
    }

    var body: some View {
        Section("Notifications") {
            // Main toggle
            Toggle(isOn: $user.notificationsEnabled) {
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "Practice Reminders"
                )
            }
            .tint(.appPrimary)
            .onChange(of: user.notificationsEnabled) { _, newValue in
                if newValue {
                    requestNotificationPermission()
                } else {
                    NotificationManager.shared.cancelAll()
                }
            }

            // Time picker (conditional)
            if user.notificationsEnabled {
                DatePicker(
                    selection: reminderTime,
                    displayedComponents: .hourAndMinute
                ) {
                    SettingsRow(
                        icon: "clock.fill",
                        iconColor: .orange,
                        title: "Reminder Time"
                    )
                }
                .onChange(of: reminderTime.wrappedValue) { _, newTime in
                    scheduleReminder(at: newTime)
                }
            }
        }
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {
                user.notificationsEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to receive practice reminders.")
        }
    }

    private func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            await MainActor.run {
                if granted {
                    scheduleReminder(at: reminderTime.wrappedValue)
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }

    private func scheduleReminder(at time: Date) {
        NotificationManager.shared.scheduleDailyReminder(at: time, userName: user.name)
    }

    private func openAppSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let user = UserProfile(name: "Luna")
    container.mainContext.insert(user)

    return List {
        NotificationsSection(user: user)
    }
    .modelContainer(container)
}
