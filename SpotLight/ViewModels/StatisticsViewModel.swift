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

    // Global

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

        let filmCount = watchedMedia.filter { $0.mediaType == .film }.count
        let serieCount = watchedMedia.filter { $0.mediaType == .serie }.count

        return GlobalStatsSummary(
            filmCount: filmCount,
            serieCount: serieCount,
            totalSessionsCount: sessions.count,
            totalDuration: totalDuration,
            averageRating: ratedMedia.isEmpty ? nil : ratedMedia.reduce(0, +) / Double(ratedMedia.count),
            reviewCount: reviewCount
        )
    }

    // Chart

    var strideUnit: (component: Calendar.Component, value: Int) {
        let dayCount = max(
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: selectedRange.start),
                to: calendar.startOfDay(for: selectedRange.end)
            ).day ?? 0,
            0
        ) + 1

        switch selectedPeriod {
        case .week:
            return (.day, 1)
        case .month:
            return (.day, max(Int(ceil(Double(dayCount) / 10.0)), 1))
        case .year:
            return (.month, 1)
        case .custom:
            if dayCount <= 7 { return (.day, 1) }
            if dayCount <= 31 { return (.day, max(Int(ceil(Double(dayCount) / 10.0)), 1)) }
            if dayCount <= 180 { return (.day, max(Int(ceil(Double(dayCount) / 16.0)), 1)) }
            if dayCount <= 365 { return (.month, 1) }
            return (.month, 2)
        }
    }

    func chartData(from mediaList: [any Media]) -> [ChartData] {
        let range = selectedRange
        let unit = strideUnit

        let sessions = mediaList.flatMap { media in
            media.interaction.watchHistory.compactMap { session -> (date: Date, duration: Int)? in
                let duration = durationForSession(media: media, session: session)
                guard range.contains(session.date), duration > 0 else {
                    return nil
                }
                return (session.date, duration)
            }
        }

        let groupedDurations = Dictionary(grouping: sessions) { session in
            bucketDate(for: session.date, in: range, unit: unit)
        }
        .mapValues { bucketSessions in
            bucketSessions.reduce(0) { $0 + $1.duration }
        }

        return chartDates(in: range, unit: unit).map { date in
            ChartData(
                date: date,
                duration: groupedDurations[date, default: 0]
            )
        }
    }

    // Favorite

    func recentMedia(from mediaList: [any Media]) -> [(media: any Media, session: WatchSession)] {
        mediaList
            .flatMap { media in
                media.interaction.watchHistory.compactMap { session -> (media: any Media, session: WatchSession)? in
                    guard session.status != .wishlist else {
                        return nil
                    }

                    return (media: media, session: session)
                }
            }
            .sorted { $0.session.date > $1.session.date }
            .prefix(5)
            .map { $0 }
    }

    func rankedGenres(from mediaList: [any Media]) -> [(label: String, count: Int)] {
        let counts = mediaList.reduce(into: [String: Int]()) { result, media in
            let sessionCount = media.interaction.watchHistory.filter { $0.status != .wishlist }.count
            guard sessionCount > 0 else {
                return
            }

            for genre in media.genres {
                result[genre.rawValue, default: 0] += sessionCount
            }
        }

        return counts
            .map { (label: $0.key, count: $0.value) }
            .sorted {
                if $0.count == $1.count { return $0.label < $1.label }
                return $0.count > $1.count
            }
            .prefix(3)
            .map { $0 }
    }

    func rankedPlatforms(from mediaList: [any Media]) -> [(label: String, count: Int)] {
        let counts = mediaList.reduce(into: [String: Int]()) { result, media in
            let sessionCount = media.interaction.watchHistory.filter { $0.status != .wishlist }.count
            guard sessionCount > 0 else {
                return
            }

            for platform in media.platforms {
                result[platform.rawValue, default: 0] += sessionCount
            }
        }

        return counts
            .map { (label: $0.key, count: $0.value) }
            .sorted {
                if $0.count == $1.count { return $0.label < $1.label }
                return $0.count > $1.count
            }
            .prefix(3)
            .map { $0 }
    }

    func favoriteGenre(from mediaList: [any Media]) -> Genre? {
        let counts = mediaList
            .flatMap { media in
                media.genres.map { ($0, media.interaction.watchHistory.filter { $0.status != .wishlist }.count) }
            }
            .reduce(into: [Genre: Int]()) { result, tuple in
                result[tuple.0, default: 0] += tuple.1
            }

        return counts.max(by: { $0.value < $1.value })?.key
    }

    func favoritePlatform(from mediaList: [any Media]) -> Platform? {
        let counts = mediaList
            .flatMap { media in
                media.platforms.map { ($0, media.interaction.watchHistory.filter { $0.status != .wishlist }.count) }
            }
            .reduce(into: [Platform: Int]()) { result, tuple in
                result[tuple.0, default: 0] += tuple.1
            }

        return counts.max(by: { $0.value < $1.value })?.key
    }

    func favoriteFilm(from mediaList: [any Media]) -> Film? {
        mediaList
            .compactMap { $0 as? Film }
            .filter { !$0.interaction.watchHistory.isEmpty }
            .sorted {
                let leftRating = $0.interaction.note ?? 0
                let rightRating = $1.interaction.note ?? 0

                if leftRating == rightRating {
                    return $0.interaction.watchHistory.count > $1.interaction.watchHistory.count
                }

                return leftRating > rightRating
            }
            .first
    }

    func favoriteSerie(from mediaList: [any Media]) -> Serie? {
        mediaList
            .compactMap { $0 as? Serie }
            .filter { !$0.interaction.watchHistory.isEmpty }
            .sorted {
                let leftRating = $0.interaction.note ?? 0
                let rightRating = $1.interaction.note ?? 0

                if leftRating == rightRating {
                    return $0.interaction.watchHistory.count > $1.interaction.watchHistory.count
                }

                return leftRating > rightRating
            }
            .first
    }

    // Private

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

    private func chartDates(
        in range: StatsRange,
        unit: (component: Calendar.Component, value: Int)
    ) -> [Date] {
        var dates: [Date] = []
        var current = bucketDate(for: range.start, in: range, unit: unit)

        while current <= range.end {
            dates.append(current)
            guard let next = calendar.date(byAdding: unit.component, value: unit.value, to: current) else {
                break
            }
            current = next
        }

        return dates
    }

    private func bucketDate(
        for date: Date,
        in range: StatsRange,
        unit: (component: Calendar.Component, value: Int)
    ) -> Date {
        switch unit.component {
        case .day:
            let baseStart = calendar.startOfDay(for: range.start)
            let currentDay = calendar.startOfDay(for: date)
            let offset = calendar.dateComponents([.day], from: baseStart, to: currentDay).day ?? 0
            let bucketOffset = (offset / unit.value) * unit.value
            return calendar.date(byAdding: .day, value: bucketOffset, to: baseStart) ?? currentDay
        case .month:
            let baseMonth = startOfMonth(for: range.start)
            let currentMonth = startOfMonth(for: date)
            let offset = calendar.dateComponents([.month], from: baseMonth, to: currentMonth).month ?? 0
            let bucketOffset = (offset / unit.value) * unit.value
            return calendar.date(byAdding: .month, value: bucketOffset, to: baseMonth) ?? currentMonth
        default:
            return date
        }
    }

    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? calendar.startOfDay(for: date)
    }
}
