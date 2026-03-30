//
//  Enums.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import Foundation

enum MediaType: String, CaseIterable, Codable {
    case film = "Film"
    case serie = "Serie"
}

enum Status: String, CaseIterable, Codable {
    case all = "Tous"
    case wishlist = "Wishlist"
    case watching = "En cours"
    case watched = "Vu"
    case abandoned = "Abandonné"
}


enum Genre: String, CaseIterable, Codable {
    case scifi = "Science Fiction"
    case fantasy = "Fantasy"
    case horror = "Horror"
    case comedy = "Comedy"
    case drama = "Drame"
    case action = "Action"
}

enum Platform: String, CaseIterable, Codable {
    case netflix = "Netflix"
    case amazonPrimeVideo = "Amazon Prime Video"
    case hulu = "Hulu"
    case disneyPlus = "Disney+"
    case canalPlus = "Canal+"
    case appleTV = "Apple TV+"
}
