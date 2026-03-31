//
//  ProfileView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(MediaViewModel.self) private var data
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

    var body: some View {
        @Bindable var profile = profile

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    profileHeader(profile: profile)
                    affinitiesSection
                    favoritesSection
                    historySection
                }
                .padding()
            }
            .navigationTitle("Profil")
        }
    }

    private func profileHeader(profile: Bindable<ProfileViewModel>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.85), Color.cyan.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "person.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName.isEmpty ? "Profil SpotLight" : profile.fullName)
                        .font(.title2.bold())
                    Text("Age: \(profile.age) ans")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            VStack(spacing: 12) {
                TextField("Prenom", text: profile.$firstName)
                    .textFieldStyle(.roundedBorder)

                TextField("Nom", text: profile.$lastName)
                    .textFieldStyle(.roundedBorder)

                Stepper(value: profile.$age, in: 1...120) {
                    Text("Age: \(profile.age) ans")
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }

    private var affinitiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Genres et plateformes")
                .font(.headline)

            affinityList(
                title: "Genres favoris",
                items: rankedGenres
            )

            affinityList(
                title: "Plateformes favorites",
                items: rankedPlatforms
            )
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Favoris")
                .font(.headline)

            favoriteBlock(title: "Film favori", media: favoriteFilm)
            favoriteBlock(title: "Serie favorite", media: favoriteSerie)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Derniers visionnages")
                .font(.headline)

            if recentMedia.isEmpty {
                Text("Aucun visionnage pour le moment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(recentMedia, id: \.id) { media in
                    NavigationLink {
                        MediaDetailView(mediaID: media.id)
                    } label: {
                        historyRow(for: media)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }

    private func affinityList(title: String, items: [(label: String, count: Int)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())

            if items.isEmpty {
                Text("Pas encore assez de visionnages.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.label) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.label)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.count)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }

                        GeometryReader { geometry in
                            let maxCount = max(items.map(\.count).max() ?? 1, 1)
                            let width = geometry.size.width * CGFloat(item.count) / CGFloat(maxCount)

                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.15))
                                Capsule()
                                    .fill(Color.blue.gradient)
                                    .frame(width: max(width, 10))
                            }
                        }
                        .frame(height: 10)
                    }
                }
            }
        }
    }

    private func favoriteBlock(title: String, media: (any Media)?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())

            if let media {
                NavigationLink {
                    MediaDetailView(mediaID: media.id)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(media.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                if media.interaction.isFavorite {
                                    Label("Favori", systemImage: "star.fill")
                                        .font(.caption.bold())
                                        .foregroundStyle(.yellow)
                                }
                            }

                            Text("\(media.creator) • \(media.releaseYear)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(favoriteExplanation(for: media))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            if let note = media.interaction.note {
                                Text(String(format: "%.1f/5", note))
                                    .font(.subheadline.bold())
                            }

                            Text("\(media.interaction.watchHistory.count) visionnage\(media.interaction.watchHistory.count > 1 ? "s" : "")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
            } else {
                Text("Aucun favori disponible pour l'instant.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func historyRow(for media: any Media) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 54, height: 72)

                Image(systemName: media.mediaType == .film ? "film" : "tv")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(media.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(media.mediaType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let date = media.interaction.lastWatchedDate {
                    Text(date.formatted(.dateTime.day().month().year()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("\(media.interaction.watchHistory.count)x")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
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
