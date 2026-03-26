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
    
    
    func addFilm(title: String, creator: String, annee: Int, duration: Int, releaseDate: Date , pays: String, platform: Platform, genres: [Genre]) {
        let newFilm = Film(
            title: title,
            creator: creator,
            pays: pays,
            description: "Aucune description",
            releaseDate: releaseDate,
            platforms: [platform],
            genres: genres,
            duration: duration
        )
        self.media.append(newFilm)
    }
    
    func addSerie(title: String, creator: String, annee: Int, duration: Int, releaseDate: Date, pays: String, platform: Platform, genres: [Genre], seasons: [Season]) {
        let newSerie = Serie(
            title: title,
            creator: creator,
            pays: pays,
            description: "Aucune description",
            releaseDate: releaseDate,
            platforms: [platform],
            genres: genres,
            seasons: seasons
        )
        self.media.append(newSerie)
    }

    func addMedia(_ media: any Media) {
        self.media.append(media)
    }
    
    func deleteMedia(indexSet: IndexSet) {
        self.media.remove(atOffsets: indexSet)
    }
}
