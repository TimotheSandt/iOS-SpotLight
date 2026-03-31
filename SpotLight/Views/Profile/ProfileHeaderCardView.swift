//
//  ProfileHeaderCardView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileHeaderCardView: View {
    var body: some View {
        @Environment(ProfileViewModel.self) var profile
        @Bindable var profile = profile

        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.85), Color.cyan.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "person.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName.isEmpty ? "Profil SpotLight" : profile.fullName)
                        .font(.title2.bold())
                    Text("Age: \(profile.age) ans")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            VStack(spacing: 12) {
                TextField("Prenom", text: $profile.firstName)
                    .textFieldStyle(.roundedBorder)

                TextField("Nom", text: $profile.lastName)
                    .textFieldStyle(.roundedBorder)

                Stepper(value: $profile.age, in: 1...120) {
                    Text("Age: \(profile.age) ans")
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
