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
}
