//
//  ProfileView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(MediaViewModel.self) var data
    @Environment(ProfileViewModel.self) private var profile
    @Environment(StatisticsViewModel.self) private var stats

    var body: some View {
        @Bindable var profile = profile

        let rankedGenres = stats.rankedGenres(from: data.media)
        let rankedPlatforms = stats.rankedPlatforms(from: data.media)
        let favoriteFilm = stats.favoriteFilm(from: data.media)
        let favoriteSerie = stats.favoriteSerie(from: data.media)
        let recentMedia = stats.recentMedia(from: data.media)
        let favoriteGenre = rankedGenres.first?.label
        let favoritePlatform = rankedPlatforms.first?.label

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderCardView(profile: profile)
                    ProfileFavoritesSectionView(
                        favoriteFilm: favoriteFilm?.title,
                        favoriteSerie: favoriteSerie?.title,
                        favoriteGenre: favoriteGenre,
                        favoritePlatform: favoritePlatform
                    )
                    ProfileHistorySectionView(recentMedia: recentMedia)
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
