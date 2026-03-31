//
//  ProfileView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderCardView()
                }
                .padding()
            }
            .navigationTitle("Profil")
        }
    }
}

#Preview {
    ProfileView()
        .environment(ProfileViewModel())
}
