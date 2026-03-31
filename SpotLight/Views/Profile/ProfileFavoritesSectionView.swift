//
//  ProfileFavoritesSectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileFavoritesSectionView: View {
    let favoriteFilm: String?
    let favoriteSerie: String?
    let favoriteGenre: String?
    let favoritePlatform: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Favoris")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ProfileFavoriteMediaCardView(title: "Film favori", value: favoriteFilm)
                ProfileFavoriteMediaCardView(title: "Serie favorite", value: favoriteSerie)
                ProfileFavoriteMediaCardView(title: "Genre favori", value: favoriteGenre)
                ProfileFavoriteMediaCardView(title: "Plateforme favorite", value: favoritePlatform)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
