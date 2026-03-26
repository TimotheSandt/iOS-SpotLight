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
    var releaseDate: Date { get set }
    var platforms: [Platform] { get set }
    var genres: [Genre] { get set }
    
    var displayDuration: Int { get }
}

struct Film: Media {
    var id = UUID()
    var title: String
    var creator: String
    var pays: String
    var description: String
    var releaseDate: Date
    var platforms: [Platform]
    var genres: [Genre]
    
    var duration: Int
    var displayDuration: Int { duration }
    
    
    
    static let testData: [Film] = [
        Film(title: "Star Wars: Episode IV - A New Hope", creator: "George Lucas", description: "A new hope for the galaxy.", releaseDate: Date(), platforms: [.disneyPlus], genres: [.action, .fantasy], duration: 135),
        Film(title: "Star Wars: Episode V - The Empire Strikes Back", creator: "George Lucas", description: "The Empire Strikes Back.", releaseDate: Date(), platforms: [.disneyPlus], genres: [.action, .fantasy], duration: 142)
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
    var releaseDate: Date
    var platforms: [Platform]
    var genres: [Genre]
    
    var seasons: [Season]
    
    
    var numberOfEpisodes: Int {
        seasons.reduce(0) { $0 + $1.episodeCount }
    }
    var TotalDuration: Int {
        seasons.reduce(0) { $0 + $1.duration }
    }
    
    var displayDuration: Int { TotalDuration }
    
    
    
    static let testData: [Serie] = [
        Serie(title: "Stranger Things", creator: "Duffer Brother", description: "demogogon", releaseDate: Date(), platforms: [.netflix], genres: [.action, .fantasy, .horror], seasons: [Season(number: 1, releaseDate: Date(), episodeCount: 9, averageDuration: 45)])
    ]
}
