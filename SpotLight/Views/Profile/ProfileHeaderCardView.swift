//
//  ProfileHeaderCardView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileHeaderCardView: View {
    @Environment(ProfileViewModel.self) private var profile
    @State private var showEditSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text(profile.fullName.isEmpty ? "Profil SpotLight" : profile.fullName)
                    .font(.title2.bold())

                Spacer()

                Button("Modifier") {
                    showEditSheet = true
                }
                .font(.subheadline.weight(.semibold))
            }

            Text("Age: \(profile.age) ans")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .sheet(isPresented: $showEditSheet) {
            ProfileEditSheetView()
        }
    }
}
