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

    private var watchedMedia: [any Media] {
        data.media.filter { !$0.interaction.watchHistory.isEmpty }
    }

    private var favoriteFilm: (any Media)? {
        favoriteMedia(for: .film)
    }

    private var favoriteSerie: (any Media)? {
        favoriteMedia(for: .serie)
    }

    private var recentMedia: [any Media] {
        watchedMedia
            .sorted { ($0.interaction.lastWatchedDate ?? .distantPast) > ($1.interaction.lastWatchedDate ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    private var rankedGenres: [(label: String, count: Int)] {
        rankedValues(from: watchedMedia.flatMap { media in
            media.genres.map(\.rawValue)
        })
    }

    private var rankedPlatforms: [(label: String, count: Int)] {
        rankedValues(from: watchedMedia.flatMap { media in
            media.platforms.map(\.rawValue)
        })
    }

    var body: some View {
        @Bindable var profile = profile

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderCardView(profile: profile)
                    ProfileAffinitiesSectionView(
                        rankedGenres: rankedGenres,
                        rankedPlatforms: rankedPlatforms
                    )
                    ProfileFavoritesSectionView(
                        favoriteFilm: favoriteFilm,
                        favoriteSerie: favoriteSerie,
                        explanation: favoriteExplanation(for:)
                    )
                    ProfileHistorySectionView(recentMedia: recentMedia)
                }
                .padding()
            }
            .navigationTitle("Profil")
        }
    }

    private func rankedValues(from values: [String]) -> [(label: String, count: Int)] {
        let counts = Dictionary(values.map { ($0, 1) }, uniquingKeysWith: +)
        return counts
            .map { (label: $0.key, count: $0.value) }
            .sorted {
                if $0.count == $1.count { return $0.label < $1.label }
                return $0.count > $1.count
            }
            .prefix(3)
            .map { $0 }
    }

    private func favoriteMedia(for type: MediaType) -> (any Media)? {
        let candidates = watchedMedia.filter { $0.mediaType == type }
        let explicitFavorites = candidates.filter { $0.interaction.isFavorite }

        if let explicit = explicitFavorites.max(by: isWeakerFavoriteCandidate) {
            return explicit
        }

        return candidates.max(by: isWeakerFavoriteCandidate)
    }

    private func isWeakerFavoriteCandidate(_ lhs: any Media, _ rhs: any Media) -> Bool {
        favoriteScore(for: lhs) < favoriteScore(for: rhs)
    }

    private func favoriteScore(for media: any Media) -> Double {
        let rating = media.interaction.note ?? 0
        let watchCount = Double(media.interaction.watchHistory.count)
        let explicitBonus = media.interaction.isFavorite ? 1_000 : 0
        return Double(explicitBonus) + (rating * 100) + (watchCount * 10)
    }

    private func favoriteExplanation(for media: any Media) -> String {
        if media.interaction.isFavorite {
            return "Choisi manuellement comme favori."
        }

        let note = media.interaction.note.map { String(format: "%.1f/5", $0) } ?? "Sans note"
        let watchCount = media.interaction.watchHistory.count
        return "\(note) • \(watchCount) visionnage\(watchCount > 1 ? "s" : "")"
    }
}

#Preview {
    ProfileView()
        .environment(MediaViewModel())
        .environment(ProfileViewModel())
}
