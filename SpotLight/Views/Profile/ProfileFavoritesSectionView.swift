//
//  ProfileFavoritesSectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileFavoritesSectionView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        @Environment(MediaViewModel.self) var data
        @Environment(StatisticsViewModel.self) var stats

        let rankedGenres = stats.rankedGenres(from: data.media)
        let rankedPlatforms = stats.rankedPlatforms(from: data.media)
        let favoriteFilm = stats.favoriteFilm(from: data.media)?.title
        let favoriteSerie = stats.favoriteSerie(from: data.media)?.title
        let favoriteGenre = rankedGenres.first?.label
        let favoritePlatform = rankedPlatforms.first?.label

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
