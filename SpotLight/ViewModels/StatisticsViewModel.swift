//
//  StatisticsViewModel.swift
//  SpotLight
//
//  Created by Codex on 30/03/2026.
//

import Foundation

@Observable
class StatisticsViewModel {

    var selectedPeriod: StatsPeriod = .month
    var customStartDate: Date
    var customEndDate: Date

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self.customStartDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.customEndDate = Date()
    }

    var selectedRange: StatsRange {
        let now = Date()
        let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEndDate) ?? customEndDate

        switch selectedPeriod {
            case .week:
                return makeRange(from: now, component: .day, value: -7)
            case .month:
                return makeRange(from: now, component: .month, value: -1)
            case .year:
                return makeRange(from: now, component: .year, value: -1)
            case .custom:
                let start = calendar.startOfDay(for: min(customStartDate, customEndDate))
                return StatsRange(start: start, end: endOfToday)
        }
    }

    var rangeLabel: String {
        let range = selectedRange
        return "\(range.start.formatted(date: .abbreviated, time: .omitted)) - \(range.end.formatted(date: .abbreviated, time: .omitted))"
    }

    func summary(from mediaList: [any Media]) -> GlobalStatsSummary {
        let mediaInRange = mediaList.filter(isMediaInRange)
        let watchedMedia = mediaInRange.filter(hasWatchedSession)
        let sessions = mediaList.flatMap(filteredSessions)

        let ratedMedia = mediaInRange.compactMap { media -> Double? in
            media.interaction.note
        }

        let reviewCount = mediaInRange.filter { media in
            media.interaction.note != nil || !(media.interaction.comment ?? "").isEmpty
        }.count

        let totalDuration = sessions.reduce(0) { partialResult, entry in
            partialResult + durationForSession(media: entry.media, session: entry.session)
        }

        let filmCount = watchedMedia.filter { $0.mediaType == MediaType.film }.count
        let serieCount = watchedMedia.filter { $0.mediaType == MediaType.serie }.count

        return GlobalStatsSummary(
            filmCount: filmCount,
            serieCount: serieCount,
            totalSessionsCount: sessions.count,
            totalDuration: totalDuration,
            averageRating: ratedMedia.isEmpty ? nil : ratedMedia.reduce(0, +) / Double(ratedMedia.count),
            reviewCount: reviewCount
        )
    }

    private func makeRange(from endDate: Date, component: Calendar.Component, value: Int) -> StatsRange {
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        let startBase = calendar.date(byAdding: component, value: value, to: end) ?? end
        return StatsRange(start: calendar.startOfDay(for: startBase), end: end)
    }

    private func isMediaInRange(_ media: any Media) -> Bool {
        guard let lastDate = media.interaction.lastWatchedDate else {
            return false
        }
        return selectedRange.contains(lastDate)
    }

    private func hasWatchedSession(_ media: any Media) -> Bool {
        media.interaction.watchHistory.contains { session in
            session.status != .wishlist && selectedRange.contains(session.date)
        }
    }

    private func filteredSessions(for media: any Media) -> [(media: any Media, session: WatchSession)] {
        media.interaction.watchHistory.compactMap { session in
            guard selectedRange.contains(session.date) else {
                return nil
            }
            return (media: media, session: session)
        }
    }

    private func durationForSession(media: any Media, session: WatchSession) -> Int {
        switch session.status {
            case .wishlist:
                return 0
            default:
                return media.displayDuration
        }
    }
    
    
    
    
    // CHART
    
    var strideUnit: (component: Calendar.Component, value: Int) {
        switch selectedPeriod {
        case .week:
            return (.day, 1)
        case .month:
            return (.day, 3) // Groupement par 3 jours comme demandé
        case .year:
            return (.month, 1)
        case .custom:
            let diff = calendar.dateComponents([.day], from: customStartDate, to: customEndDate).day ?? 0
            if diff <= 7 { return (.day, 1) }
            if diff <= 31 { return (.day, 3) }
            if diff <= 365 { return (.day, 7) }
            if diff <= 365 * 2 { return (.month, 1) }
            return (.month, 3)
        }
    }

    func chartData(from mediaList: [any Media]) -> [ChartData] {
        let range = selectedRange
        let unit = strideUnit
        
        // 1. Extraire toutes les sessions dans la plage
        let sessions = mediaList.flatMap { media in
            media.interaction.watchHistory.compactMap { session -> (Date, Int)? in
                guard range.contains(session.date) else { return nil }
                return (session.date, durationForSession(media: media, session: session))
            }
        }
        
        // 2. Grouper les sessions selon l'unité calculée
        let grouped = Dictionary(grouping: sessions) { (date, _) in
            if unit.component == .day && unit.value > 1 {
                let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
                let groupedDay = (dayOfYear / unit.value) * unit.value
                var components = calendar.dateComponents([.year], from: date)
                components.day = groupedDay
                return calendar.date(from: components) ?? date
            }
            return calendar.dateInterval(of: unit.component, for: date)?.start ?? date
        }
        
        return grouped.map { (date, sessions) in
            ChartData(date: date, duration: sessions.reduce(0) { $0 + $1.1 })
        }.sorted { $0.date < $1.date }
    }
}
