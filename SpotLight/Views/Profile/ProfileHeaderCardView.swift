//
//  ProfileHeaderCardView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileHeaderCardView: View {
    @Environment(ProfileViewModel.self) private var profile

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(profile.fullName.isEmpty ? "Profil SpotLight" : profile.fullName)
                .font(.title2.bold())

            Text("Age: \(profile.age) ans")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(
                "Prenom",
                text: Binding(
                    get: { profile.firstName },
                    set: { profile.firstName = $0 }
                )
            )
            .textFieldStyle(.roundedBorder)

            TextField(
                "Nom",
                text: Binding(
                    get: { profile.lastName },
                    set: { profile.lastName = $0 }
                )
            )
            .textFieldStyle(.roundedBorder)

            Stepper(
                value: Binding(
                    get: { profile.age },
                    set: { profile.age = $0 }
                ),
                in: 1...120
            ) {
                Text("Age: \(profile.age) ans")
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
