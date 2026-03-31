//
//  StatisticsView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI


struct StatisticsView: View {

    @Environment(MediaViewModel.self) private var data
    @Environment(StatisticsViewModel.self) private var stats

    private var summary: GlobalStatsSummary {
        stats.summary(from: data.media)
    }

    var body: some View {
        @Bindable var stats = stats
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Periode")
                            .font(.headline)

                        Picker("Periode", selection: $stats.selectedPeriod) {
                            ForEach(StatsPeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)

                        if stats.selectedPeriod == .custom {
                            VStack(spacing: 12) {
                                DatePicker("Debut", selection: $stats.customStartDate, displayedComponents: .date)
                                DatePicker("Fin", selection: $stats.customEndDate, displayedComponents: .date)
                            }
                        }

                        Text(stats.rangeLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(18)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),  GridItem(.flexible())], spacing: 8) {
                        StatsCardView(
                            title: "Film vus",
                            value: "\(summary.filmCount)"
                        )
                        
                        StatsCardView(
                            title: "Série vus",
                            value: "\(summary.serieCount)"
                        )
                        
                        StatsCardView(
                            title: "Sessions",
                            value: "\(summary.totalSessionsCount)"
                        )
                        
                        StatsCardView(
                            title: "Temps passé",
                            value: formatDuration(summary.totalDuration)
                        )
                        
                        StatsCardView(
                            title: "Note moyenne",
                            value: summary.averageRating.map { String(format: "%.1f/5", $0) } ?? "-"
                        )
                        
                        StatsCardView(
                            title: "Nombre d'avis",
                            value: "\(summary.reviewCount)",
                        )
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
}

#Preview {
    StatisticsView()
        .environment(MediaViewModel())
        .environment(StatisticsViewModel())
}
