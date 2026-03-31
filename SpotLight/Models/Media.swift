//
//  Film.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//


import Foundation


protocol Media: Identifiable, Codable {
    var id: UUID { get }
    var title: String { get set }
    var creator: String { get set }
    var pays: String { get set }
    var description: String { get set }
    var releaseYear: Int { get set }
    var platforms: [Platform] { get set }
    var genres: [Genre] { get set }
    
    var displayDuration: Int { get }
    var mediaType: MediaType { get }
    
    var interaction: MediaInteraction { get set }
}

struct Film: Media {
    var id = UUID()
    var title: String
    var creator: String
    var pays: String
    var description: String
    var releaseYear: Int
    var platforms: [Platform]
    var genres: [Genre]
    
    var duration: Int
    var displayDuration: Int { duration }
    
    var mediaType: MediaType { .film }
    
    var interaction: MediaInteraction = .init()
    
    
    static let testData: [Film] = [
        // CAS 1 : Film vu (Status .watched) avec une date
        Film(title: "Inception", creator: "Christopher Nolan", pays: "USA",
             description: "Un voleur qui infiltre les rêves.", releaseYear: 2010,
             platforms: [.netflix], genres: [.action, .scifi], duration: 148,
             interaction: MediaInteraction(
                status: .watched,
                note: 4.5,
                comment: "Incroyable, à revoir !",
                watchHistory: [WatchSession(date: Date().addingTimeInterval(-86400 * 10), status: .watched)] // Vu il y a 10 jours
             )),
        
        // CAS 2 : Film en Wishlist (interaction par défaut)
        Film(title: "Dune: Part Two", creator: "Denis Villeneuve", pays: "USA",
             description: "La suite du voyage mythique de Paul Atreides.", releaseYear: 2024,
             platforms: [.canalPlus], genres: [.scifi, .drama], duration: 166),
        
        // CAS 3 : Film
        Film(title: "Sharknado", creator: "Anthony C. Ferrante", pays: "USA",
             description: "Des requins dans une tornade.", releaseYear: 2013,
             platforms: [.amazonPrimeVideo], genres: [.horror, .comedy], duration: 87,
             interaction: MediaInteraction(status: .watched, comment: "Trop nanar pour moi."))
    ]
        
}

struct Season: Identifiable, Codable {
    var id = UUID()
    var number: Int
    var releaseDate: Date
    var episodeCount: Int
    
    var averageDuration: Int
    var duration: Int {
        averageDuration * episodeCount
    }
}

struct Serie: Media {
    var id = UUID()
    var title: String
    var creator: String
    var pays: String
    var description: String
    var releaseYear: Int
    var platforms: [Platform]
    var genres: [Genre]
    
    var seasons: [Season]
    
    var mediaType: MediaType { .serie }
    
    var interaction: MediaInteraction = .init()
    
    
    var numberOfEpisodes: Int {
        seasons.reduce(0) { $0 + $1.episodeCount }
    }
    var TotalDuration: Int {
        seasons.reduce(0) { $0 + $1.duration }
    }
    
    var displayDuration: Int { TotalDuration }
    var averageEpisodeDuration: Int {
        guard numberOfEpisodes > 0 else {
            return 0
        }

        return TotalDuration / numberOfEpisodes
    }

    func season(number: Int) -> Season? {
        seasons.first { $0.number == number }
    }
    
    
    
    static let testData: [Serie] = [
        // CAS 1 : Série en cours (Watching)
        Serie(title: "The Bear", creator: "Christopher Storer", pays: "USA",
              description: "Le stress d'une cuisine professionnelle.", releaseYear: 2022,
              platforms: [.disneyPlus], genres: [.drama, .comedy],
              seasons: [
                Season(number: 1, releaseDate: Date(), episodeCount: 8, averageDuration: 30),
                Season(number: 2, releaseDate: Date(), episodeCount: 10, averageDuration: 35)
              ],
              interaction: MediaInteraction(
                status: .watching,
                watchHistory: [WatchSession(date: Date(), status: .watching)] // Dernière session aujourd'hui
              )),
        
        // CAS 2 : Série terminée (Watched)
        Serie(title: "Breaking Bad", creator: "Vince Gilligan", pays: "USA",
              description: "Un prof de chimie devient baron de la drogue.", releaseYear: 2008,
              platforms: [.netflix], genres: [.drama, .action],
              seasons: [Season(number: 1, releaseDate: Date(), episodeCount: 7, averageDuration: 47)],
              interaction: MediaInteraction(
                status: .watched,
                note: 5.0,
                watchHistory: [WatchSession(date: Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 25))!, status: .watched)]
              )),
        
        // CAS 3 : Série en Wishlist
        Serie(title: "Severance", creator: "Dan Erickson", pays: "USA",
              description: "L'équilibre travail-vie privée poussé à l'extrême.", releaseYear: 2022,
              platforms: [.appleTV], genres: [.scifi, .drama],
              seasons: [Season(number: 1, releaseDate: Date(), episodeCount: 9, averageDuration: 50)])
    ]
}


func formatDuration(_ duration: Int) -> String {
    let hours = duration / 60
    let minutes = duration.remainderReportingOverflow(dividingBy: 60).partialValue
    
    if hours == 0 {
        return "\(minutes) min"
    } else {
        return "\(hours) h \(minutes) min"
    }
}
