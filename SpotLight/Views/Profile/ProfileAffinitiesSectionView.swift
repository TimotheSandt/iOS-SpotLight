//
//  ProfileAffinitiesSectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileAffinitiesSectionView: View {
    let rankedGenres: [(label: String, count: Int)]
    let rankedPlatforms: [(label: String, count: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Genres et plateformes")
                .font(.headline)

            ProfileAffinityListView(
                title: "Genres favoris",
                items: rankedGenres
            )

            ProfileAffinityListView(
                title: "Plateformes favorites",
                items: rankedPlatforms
            )
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
