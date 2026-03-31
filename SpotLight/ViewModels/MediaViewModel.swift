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

    
    func recentMedia() -> [any Media] {
        media
            .filter { !$0.interaction.watchHistory.isEmpty }
            .sorted { ($0.interaction.lastWatchedDate ?? .distantPast) > ($1.interaction.lastWatchedDate ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    func getFavoriteGenre() -> [(label: String, count: Int)] {
        let genresCount = media
            .flatMap { media in media.genres.map { ($0.rawValue, media.interaction.watchHistory.count) } }
            .reduce(into: [String: Int]()) { result, tuple in
                result[tuple.0, default: 0] += tuple.1
            }
        
        // On retourne le top 1 (ou vide si rien)
        if let favorite = genresCount.max(by: { $0.value < $1.value }) {
            return [(label: favorite.key, count: favorite.value)]
        }
        return []
    }

    func getFavoritePlatforms() -> [(label: String, count: Int)] {
        let platformsCount = media
            .flatMap { media in media.platforms.map { ($0.rawValue, media.interaction.watchHistory.count) } }
            .reduce(into: [String: Int]()) { result, tuple in
                result[tuple.0, default: 0] += tuple.1
            }
        
        if let favorite = platformsCount.max(by: { $0.value < $1.value }) {
            return [(label: favorite.key, count: favorite.value)]
        }
        return []
    }

    func getFavoriteFilm() -> Film? {
        // 1. On cherche d'abord s'il y a un favori explicite
        if let explicitFavorite = media.first(where: { $0.interaction.isFavorite && $0 is Film }) as? Film {
            return explicitFavorite
        }
        
        // 2. Sinon, on filtre tous les films pour trouver le meilleur
        let allFilms = media.compactMap { $0 as? Film }
        
        // 3. On trie par note, puis par nombre de visionnages
        return allFilms.sorted { lhs, rhs in
            let noteLhs = lhs.interaction.note ?? 0
            let noteRhs = rhs.interaction.note ?? 0
            
            if noteLhs != noteRhs {
                return noteLhs > noteRhs
            }
            return lhs.interaction.watchHistory.count > rhs.interaction.watchHistory.count
        }.first
    }

    func getFavoriteSerie() -> Serie? {
        // 1. On cherche d'abord s'il y a un favori explicite
        if let explicitFavorite = media.first(where: { $0.interaction.isFavorite && $0 is Serie }) as? Serie {
            return explicitFavorite
        }
        
        // 2. Sinon, on filtre toutes les séries
        let allSeries = media.compactMap { $0 as? Serie }
        
        // 3. Tri identique
        return allSeries.sorted { lhs, rhs in
            let noteLhs = lhs.interaction.note ?? 0
            let noteRhs = rhs.interaction.note ?? 0
            
            if noteLhs != noteRhs {
                return noteLhs > noteRhs
            }
            return lhs.interaction.watchHistory.count > rhs.interaction.watchHistory.count
        }.first
    }
    
    func addFilm(title: String, creator: String, annee: Int, duration: Int, releaseYear: Int , pays: String, platform: Platform, genres: [Genre], status: Status, note: Double?, comment: String?, date: Date?) {
        var watchHistory: [WatchSession] = []
        if (date != nil) {
            watchHistory.append(WatchSession(date: date!, status: .watched))
        }
        
        let interaction: MediaInteraction = MediaInteraction(
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
        if (date != nil) {
            watchHistory.append(WatchSession(date: date!, status: .watched))
        }
        
        let interaction: MediaInteraction = MediaInteraction(
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

    func addWatchSession(for id: UUID, status: Status, date: Date) {
        updateMedia(withID: id) { media in
            media.interaction.watchHistory.append(WatchSession(date: date, status: status))
            media.interaction.status = status
        }
    }

    func toggleFavorite(for id: UUID) {
        let selectedMedia = media.first { $0.id == id }
        
        // Si on veut mettre en favori, on retire l'ancien favori du même type
        if let selected = selectedMedia, !selected.interaction.isFavorite {
            let sameTypeFavorites = media.filter {
                $0.interaction.isFavorite && type(of: $0) == type(of: selected)
            }
            
            for fav in sameTypeFavorites {
                updateMedia(withID: fav.id) { $0.interaction.isFavorite = false }
            }
        }
        
        updateMedia(withID: id) { $0.interaction.isFavorite.toggle() }
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
