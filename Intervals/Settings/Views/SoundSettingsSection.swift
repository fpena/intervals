//
//  SoundSettingsSection.swift
//  Intervals
//

import SwiftUI
import SwiftData

struct SoundSettingsSection: View {
    @Bindable var user: UserProfile
    @AppStorage("masterVolume") private var masterVolume: Double = 0.8

    var body: some View {
        Section("Sound & Haptics") {
            // Volume slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(.blue)
                    Text("Volume")
                    Spacer()
                    Text("\(Int(masterVolume * 100))%")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Slider(value: $masterVolume, in: 0...1)
                    .tint(.appPrimary)
            }
            .padding(.vertical, 4)

            // Haptics toggle
            Toggle(isOn: $user.hapticsEnabled) {
                SettingsRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: .green,
                    title: "Haptics"
                )
            }
            .tint(.appPrimary)

            // Sound effects toggle
            Toggle(isOn: $user.soundEnabled) {
                SettingsRow(
                    icon: "music.note",
                    iconColor: .pink,
                    title: "Sound Effects"
                )
            }
            .tint(.appPrimary)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let user = UserProfile(name: "Luna")
    container.mainContext.insert(user)

    return List {
        SoundSettingsSection(user: user)
    }
    .modelContainer(container)
}
