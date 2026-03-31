//
//  MediaViewModel.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import Foundation
import SwiftUI

@Observable
class MediaViewModel {
    
    var media: [any Media] = []
    
    init() {
        self.media.append(contentsOf: Film.testData)
        self.media.append(contentsOf: Serie.testData)
    }
    
    func addMedia(_ media: any Media) {
        self.media.append(media)
    }

    func media(withID id: UUID) -> (any Media)? {
        media.first { $0.id == id }
    }
    
    // MODIFIERS
    func addFilm(title: String, creator: String, annee: Int, duration: Int, releaseYear: Int , pays: String, platform: Platform, genres: [Genre], status: Status, note: Double?, comment: String?, date: Date?) {
        var watchHistory: [WatchSession] = []
        if date != nil {
            watchHistory.append(WatchSession(date: date!, status: .watched))
        }
        
        let interaction = MediaInteraction(
            status: status,
            note: note,
            comment: comment,
            watchHistory: watchHistory
        )
        
        let newFilm = Film(
            title: title,
            creator: creator,
            pays: pays,
            description: "Aucune description",
            releaseYear: releaseYear,
            platforms: [platform],
            genres: genres,
            duration: duration,
            interaction: interaction
        )
        self.media.append(newFilm)
    }
    
    func addSerie(title: String, creator: String, annee: Int, duration: Int, releaseYear: Int, pays: String, platform: Platform, genres: [Genre], seasons: [Season], status: Status, note: Double?, comment: String?, date: Date?) {
        var watchHistory: [WatchSession] = []
        if date != nil {
            watchHistory.append(WatchSession(date: date!, status: .watched))
        }
        
        let interaction = MediaInteraction(
            status: status,
            note: note,
            comment: comment,
            watchHistory: watchHistory
        )
        
        let newSerie = Serie(
            title: title,
            creator: creator,
            pays: pays,
            description: "Aucune description",
            releaseYear: releaseYear,
            platforms: [platform],
            genres: genres,
            seasons: seasons,
            interaction: interaction
        )
        self.media.append(newSerie)
    }

    func deleteMedia(indexSet: IndexSet) {
        self.media.remove(atOffsets: indexSet)
    }

    func updateAvis(for id: UUID, note: Double?, comment: String?) {
        updateMedia(withID: id) { media in
            media.interaction.note = note
            media.interaction.comment = comment
        }
    }

    func addWatchSession(
        for id: UUID,
        status: Status,
        date: Date,
        seasonNumber: Int? = nil,
        episodeNumber: Int? = nil
    ) {
        updateMedia(withID: id) { media in
            media.interaction.watchHistory.append(
                WatchSession(
                    date: date,
                    status: status,
                    seasonNumber: seasonNumber,
                    episodeNumber: episodeNumber
                )
            )
            media.interaction.status = status
        }
    }

    func nextEpisodeToWatch(for id: UUID) -> (seasonNumber: Int, episodeNumber: Int)? {
        guard let serie = media(withID: id) as? Serie else {
            return nil
        }

        let orderedSeasons = serie.seasons.sorted(by: { $0.number < $1.number })
        guard let firstSeason = orderedSeasons.first else {
            return nil
        }

        let lastEpisodeSession = serie.interaction.watchHistory
            .filter { $0.status != .wishlist && $0.seasonNumber != nil && $0.episodeNumber != nil }
            .sorted { $0.date > $1.date }
            .first

        guard let lastEpisodeSession,
              let seasonNumber = lastEpisodeSession.seasonNumber,
              let episodeNumber = lastEpisodeSession.episodeNumber else {
            let watchedCount = serie.interaction.watchHistory.filter { $0.status != .wishlist }.count
            if watchedCount == 0 {
                return (firstSeason.number, 1)
            }

            var remainingIndex = watchedCount + 1

            for season in orderedSeasons {
                if remainingIndex <= season.episodeCount {
                    return (season.number, remainingIndex)
                }
                remainingIndex -= season.episodeCount
            }

            return nil
        }

        if let currentSeason = serie.season(number: seasonNumber),
           episodeNumber < currentSeason.episodeCount {
            return (seasonNumber, episodeNumber + 1)
        }

        guard let currentSeasonIndex = orderedSeasons.firstIndex(where: { $0.number == seasonNumber }),
              currentSeasonIndex + 1 < orderedSeasons.count else {
            return nil
        }

        return (orderedSeasons[currentSeasonIndex + 1].number, 1)
    }

    func addNextEpisodeSession(for id: UUID, status: Status = .watched, date: Date = Date()) {
        guard let nextEpisode = nextEpisodeToWatch(for: id) else {
            return
        }

        addWatchSession(
            for: id,
            status: status,
            date: date,
            seasonNumber: nextEpisode.seasonNumber,
            episodeNumber: nextEpisode.episodeNumber
        )
    }

    func toggleFavorite(for id: UUID) {
        guard let selectedMedia = media(withID: id) else {
            return
        }

        if !selectedMedia.interaction.isFavorite {
            let sameTypeFavorites = media.filter {
                $0.interaction.isFavorite && $0.mediaType == selectedMedia.mediaType
            }

            for favorite in sameTypeFavorites {
                updateMedia(withID: favorite.id) { media in
                    media.interaction.isFavorite = false
                }
            }
        }

        updateMedia(withID: id) { media in
            media.interaction.isFavorite.toggle()
        }
    }

    private func updateMedia(withID id: UUID, mutate: (inout any Media) -> Void) {
        guard let index = media.firstIndex(where: { $0.id == id }) else {
            return
        }

        var item = media[index]
        mutate(&item)
        media[index] = item
    }
}
