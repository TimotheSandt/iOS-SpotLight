//
//  ProfileView.swift
//  SpotLight
//
//  Created by timothe sandt on 31/03/2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderCardView()
                    ProfileFavoritesSectionView()
                    ProfileHistorySectionView()
                }
                .padding()
            }
            .navigationTitle("Profil")
        }
    }
}

#Preview {
    ProfileView()
        .environment(MediaViewModel())
        .environment(ProfileViewModel())
        .environment(StatisticsViewModel())
}
