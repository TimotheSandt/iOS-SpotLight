//
//  StatisticsViewModel.swift
//  SpotLight
//
//  Created by timothe sandt on 30/03/2026.
//

import Foundation

@Observable
class StatisticsViewModel {
    // --- PROPRIÉTÉS ---
    var selectedPeriod: StatsPeriod = .month
    var customStartDate: Date
    var customEndDate: Date
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self.customStartDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.customEndDate = Date()
    }

    // --- CALCUL DE LA PÉRIODE (Plage de dates) ---
    var selectedRange: StatsRange {
        let now = Date()
        let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEndDate) ?? customEndDate

        switch selectedPeriod {
        case .week:  return makeRange(from: now, component: .day, value: -7)
        case .month: return makeRange(from: now, component: .month, value: -1)
        case .year:  return makeRange(from: now, component: .year, value: -1)
        case .custom:
            let start = calendar.startOfDay(for: min(customStartDate, customEndDate))
            return StatsRange(start: start, end: endOfToday)
        }
    }
    
    var rangeLabel: String {
        let range = selectedRange
        let startStr = range.start.formatted(date: .abbreviated, time: .omitted)
        let endStr = range.end.formatted(date: .abbreviated, time: .omitted)
        
        return "\(startStr) - \(endStr)"
    }

    // --- RÉSUMÉ GLOBAL ---
    func summary(from mediaList: [any Media]) -> GlobalStatsSummary {
        let range = selectedRange
        var filmCount = 0
        var serieCount = 0
        var totalDuration = 0
        var sessionCount = 0
        var ratings: [Double] = []
        var reviewCount = 0

        for media in mediaList {
            // On récupère les sessions qui sont dans la bonne date
            let sessionsInRange = media.interaction.watchHistory.filter {
                range.contains($0.date) && $0.status != .wishlist
            }

            if !sessionsInRange.isEmpty {
                // Type de média
                if media.mediaType == .film { filmCount += 1 } else { serieCount += 1 }
                
                // Sessions et Temps
                sessionCount += sessionsInRange.count
                totalDuration += sessionsInRange.count * media.displayDuration
                
                // Notes et Avis
                if let note = media.interaction.note { ratings.append(note) }
                if media.interaction.note != nil || !(media.interaction.comment ?? "").isEmpty {
                    reviewCount += 1
                }
            }
        }

        return GlobalStatsSummary(
            filmCount: filmCount,
            serieCount: serieCount,
            totalSessionsCount: sessionCount,
            totalDuration: totalDuration,
            averageRating: ratings.isEmpty ? nil : ratings.reduce(0, +) / Double(ratings.count),
            reviewCount: reviewCount
        )
    }

    // --- DONNÉES DU GRAPHIQUE (La partie technique) ---
    var strideUnit: (component: Calendar.Component, value: Int) {
        let dayCount = calendar.dateComponents([.day], from: selectedRange.start, to: selectedRange.end).day ?? 0
        
        switch selectedPeriod {
        case .week:  return (.day, 1)
        case .month: return (.day, max(dayCount / 10, 1))
        case .year:  return (.month, 1)
        case .custom:
            if dayCount <= 7 { return (.day, 1) }
            if dayCount <= 31 { return (.day, max(dayCount / 10, 1)) }
            return (.month, 1)
        }
    }

    func chartData(from mediaList: [any Media]) -> [ChartData] {
        let range = selectedRange
        let unit = strideUnit
        var groupedDurations: [Date: Int] = [:]

        for media in mediaList {
            for session in media.interaction.watchHistory {
                let duration = (session.status != .wishlist) ? media.displayDuration : 0
                if range.contains(session.date) && duration > 0 {
                    let bucket = bucketDate(for: session.date, in: range, unit: unit)
                    groupedDurations[bucket, default: 0] += duration
                }
            }
        }

        return chartDates(in: range, unit: unit).map { date in
            ChartData(date: date, duration: groupedDurations[date, default: 0])
        }
    }

    // --- CLASSEMENTS ET FAVORIS ---
    func rankedGenres(from mediaList: [any Media]) -> [(label: String, count: Int)] {
        var counts: [String: Int] = [:]
        for media in mediaList {
            let viewCount = media.interaction.watchHistory.filter { $0.status != .wishlist }.count
            for genre in media.genres where viewCount > 0 {
                counts[genre.rawValue, default: 0] += viewCount
            }
        }
        return counts.map { (label: $0.key, count: $0.value) }.sorted { $0.count > $1.count }
    }

    func rankedPlatforms(from mediaList: [any Media]) -> [(label: String, count: Int)] {
        var counts: [String: Int] = [:]
        for media in mediaList {
            let viewCount = media.interaction.watchHistory.filter { $0.status != .wishlist }.count
            for plat in media.platforms where viewCount > 0 {
                counts[plat.rawValue, default: 0] += viewCount
            }
        }
        return counts.map { (label: $0.key, count: $0.value) }.sorted { $0.count > $1.count }
    }

    func favoriteGenre(from mediaList: [any Media]) -> Genre? {
        if let top = rankedGenres(from: mediaList).first { return Genre(rawValue: top.label) }
        return nil
    }

    func favoritePlatform(from mediaList: [any Media]) -> Platform? {
        if let top = rankedPlatforms(from: mediaList).first { return Platform(rawValue: top.label) }
        return nil
    }

    func favoriteFilm(from mediaList: [any Media]) -> Film? {
        return mediaList.compactMap { $0 as? Film }
            .filter { !$0.interaction.watchHistory.isEmpty }
            .sorted { ($0.interaction.note ?? 0, $0.interaction.watchHistory.count) > ($1.interaction.note ?? 0, $1.interaction.watchHistory.count) }
            .first
    }

    func favoriteSerie(from mediaList: [any Media]) -> Serie? {
        return mediaList.compactMap { $0 as? Serie }
            .filter { !$0.interaction.watchHistory.isEmpty }
            .sorted { ($0.interaction.note ?? 0, $0.interaction.watchHistory.count) > ($1.interaction.note ?? 0, $1.interaction.watchHistory.count) }
            .first
    }

    func recentMedia(from mediaList: [any Media]) -> [(media: any Media, session: WatchSession)] {
        var results: [(media: any Media, session: WatchSession)] = []
        for media in mediaList {
            for session in media.interaction.watchHistory where session.status != .wishlist {
                results.append((media, session))
            }
        }
        return results.sorted { $0.session.date > $1.session.date }.prefix(5).map { $0 }
    }

    // --- OUTILS PRIVÉS (CALCULS DE DATES) ---
    private func makeRange(from end: Date, component: Calendar.Component, value: Int) -> StatsRange {
        let e = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
        let s = calendar.date(byAdding: component, value: value, to: e) ?? e
        return StatsRange(start: calendar.startOfDay(for: s), end: e)
    }

    private func bucketDate(for date: Date, in range: StatsRange, unit: (component: Calendar.Component, value: Int)) -> Date {
        if unit.component == .day {
            let offset = calendar.dateComponents([.day], from: range.start, to: date).day ?? 0
            let bucketOffset = (offset / unit.value) * unit.value
            return calendar.date(byAdding: .day, value: bucketOffset, to: calendar.startOfDay(for: range.start)) ?? date
        } else {
            let components = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: components) ?? date
        }
    }

    private func chartDates(in range: StatsRange, unit: (component: Calendar.Component, value: Int)) -> [Date] {
        var dates: [Date] = []
        var current = bucketDate(for: range.start, in: range, unit: unit)
        while current <= range.end {
            dates.append(current)
            current = calendar.date(byAdding: unit.component, value: unit.value, to: current) ?? Date.distantFuture
        }
        return dates
    }
}
