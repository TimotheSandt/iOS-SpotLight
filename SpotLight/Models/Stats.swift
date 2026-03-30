//
//  Stats.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//


private enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "Semaine"
    case month = "Mois"
    case year = "Annee"
    case custom = "Personnalisee"

    var id: Self { self }
}

private struct StatsRange {
    let start: Date
    let end: Date

    func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }
}

private struct GlobalStatsSummary {
    let watchedMediaCount: Int
    let totalSessionsCount: Int
    let totalDuration: Int
    let averageRating: Double?
    let reviewCount: Int
    let filmCount: Int
    let serieCount: Int
}