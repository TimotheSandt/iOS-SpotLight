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

    private var rankedGenres: [(label: String, count: Int)] {
        stats.rankedGenres(from: data.media)
    }

    private var rankedPlatforms: [(label: String, count: Int)] {
        stats.rankedPlatforms(from: data.media)
    }

    private var favoriteFilm: String? {
        stats.favoriteFilm(from: data.media)?.title
    }

    private var favoriteSerie: String? {
        stats.favoriteSerie(from: data.media)?.title
    }

    private var favoriteGenre: String? {
        rankedGenres.first?.label
    }

    private var favoritePlatform: String? {
        rankedPlatforms.first?.label
    }

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
