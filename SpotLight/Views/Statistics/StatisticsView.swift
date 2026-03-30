//
//  StatisticsView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI


struct StatisticsView: View {

    @Environment(MediaViewModel.self) private var data

    @State private var selectedPeriod: StatsPeriod = .month
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var customEndDate = Date()

    private let calendar = Calendar.current

    private var selectedRange: StatsRange {
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

    private var summary: GlobalStatsSummary {
        let mediaInRange = data.media.filter(isMediaInRange)
        let watchedMedia = mediaInRange.filter(hasWatchedSession)
        let sessions = data.media.flatMap(filteredSessions)

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
            watchedMediaCount: watchedMedia.count,
            totalSessionsCount: sessions.count,
            totalDuration: totalDuration,
            averageRating: ratedMedia.isEmpty ? nil : ratedMedia.reduce(0, +) / Double(ratedMedia.count),
            reviewCount: reviewCount,
            filmCount: filmCount,
            serieCount: serieCount
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Periode")
                            .font(.headline)

                        Picker("Periode", selection: $selectedPeriod) {
                            ForEach(StatsPeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)

                        if selectedPeriod == .custom {
                            VStack(spacing: 12) {
                                DatePicker("Debut", selection: $customStartDate, displayedComponents: .date)
                                DatePicker("Fin", selection: $customEndDate, displayedComponents: .date)
                            }
                        }

                        Text(rangeLabel(for: selectedRange))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(18)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatsCardView(title: "Medias vus", value: "\(summary.watchedMediaCount)", subtitle: "au moins un visionnage termine")
                        StatsCardView(title: "Temps passe", value: formatDuration(summary.totalDuration), subtitle: "\(summary.totalSessionsCount) session(s)")
                        StatsCardView(title: "Note moyenne", value: summary.averageRating.map { String(format: "%.1f/5", $0) } ?? "-", subtitle: "sur les medias notes")
                        StatsCardView(title: "Nombre d'avis", value: "\(summary.reviewCount)", subtitle: "commentaire ou note")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Repartition")
                            .font(.headline)

                        HStack(spacing: 12) {
                            StatsHighlightView(title: "Films", value: "\(summary.filmCount)")
                            StatsHighlightView(title: "Series", value: "\(summary.serieCount)")
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Definition")
                            .font(.headline)

                        Text("Les stats de visionnage utilisent l'historique sur la periode selectionnee. Pour les avis et la note moyenne, la periode est basee sur la derniere activite du media.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Statistiques")
        }
    }

    private func makeRange(from endDate: Date, component: Calendar.Component, value: Int) -> StatsRange {
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        let startBase = calendar.date(byAdding: component, value: value, to: end) ?? end
        return StatsRange(start: calendar.startOfDay(for: startBase), end: end)
    }

    private func rangeLabel(for range: StatsRange) -> String {
        "\(range.start.formatted(date: .abbreviated, time: .omitted)) - \(range.end.formatted(date: .abbreviated, time: .omitted))"
    }

    private func isMediaInRange(_ media: any Media) -> Bool {
        guard let lastDate = media.interaction.lastWatchedDate else {
            return false
        }
        return selectedRange.contains(lastDate)
    }

    private func hasWatchedSession(_ media: any Media) -> Bool {
        media.interaction.watchHistory.contains { session in
            session.status == .watched && selectedRange.contains(session.date)
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

#Preview {
    StatisticsView()
        .environment(MediaViewModel())
}
