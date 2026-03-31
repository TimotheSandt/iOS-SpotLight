//
//  ProfileFavoritesSectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileFavoritesSectionView: View {
    let favoriteFilm: (any Media)?
    let favoriteSerie: (any Media)?
    let explanation: (any Media) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Favoris")
                .font(.headline)

            ProfileFavoriteMediaCardView(
                title: "Film favori",
                media: favoriteFilm,
                explanation: explanation
            )

            ProfileFavoriteMediaCardView(
                title: "Serie favorite",
                media: favoriteSerie,
                explanation: explanation
            )
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
