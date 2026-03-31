//
//  ProfileFavoritesSectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileFavoritesSectionView: View {
    @Environment(MediaViewModel.self) private var data
    @Environment(StatisticsViewModel.self) private var stats

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Favoris")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ProfileFavoriteMediaCardView(title: "Film favori", value: stats.favoriteFilm(from: data.media)?.title ?? "N/A")
                ProfileFavoriteMediaCardView(title: "Serie favorite", value: stats.favoriteSerie(from: data.media)?.title ?? "N/A")
                ProfileFavoriteMediaCardView(title: "Genre favori", value: stats.favoriteGenre(from: data.media)?.rawValue ?? "N/A")
                ProfileFavoriteMediaCardView(title: "Plateforme favorite", value: stats.favoritePlatform(from: data.media)?.rawValue ?? "N/A")
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
