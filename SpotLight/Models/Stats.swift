//
//  Stats.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import Foundation

enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "Semaine"
    case month = "Mois"
    case year = "Annee"
    case custom = "Personnalisee"

    var id: Self { self }
}

struct StatsRange {
    let start: Date
    let end: Date

    func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }
}

struct GlobalStatsSummary {
    let filmCount: Int
    let serieCount: Int
    let totalSessionsCount: Int
    let totalDuration: Int
    let averageRating: Double?
    let reviewCount: Int

    static let empty = GlobalStatsSummary(
        filmCount: 0,
        serieCount: 0,
        totalSessionsCount: 0,
        totalDuration: 0,
        averageRating: nil,
        reviewCount: 0
    )
}
