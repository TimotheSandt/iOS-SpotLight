//
//  Enums.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import Foundation

enum Genre: String, CaseIterable, Codable {
    case scienceFiction = "Science Fiction"
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

enum Status: String, CaseIterable, Codable {
    case all = "Tous"
    case toWatch = "À voir"
    case watching = "En cours"
    case watched = "Terminé"
    case abandoned = "Abandonné"
}
