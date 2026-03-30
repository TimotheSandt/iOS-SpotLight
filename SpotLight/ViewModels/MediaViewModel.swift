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
    
    func addFilm(title: String, creator: String, annee: Int, duration: Int, releaseDate: Date , pays: String, platform: Platform, genres: [Genre], status: Status, note: Double?, comment: String?, date: Date?) {
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
            releaseDate: releaseDate,
            platforms: [platform],
            genres: genres,
            duration: duration,
            interaction: interaction
        )
        self.media.append(newFilm)
    }
    
    func addSerie(title: String, creator: String, annee: Int, duration: Int, releaseDate: Date, pays: String, platform: Platform, genres: [Genre], seasons: [Season], status: Status, note: Double?, comment: String?, date: Date?) {
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
            releaseDate: releaseDate,
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
}
