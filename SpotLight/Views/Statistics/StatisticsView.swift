//
//  StatisticsView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI


struct StatisticsView: View {

    @Environment(MediaViewModel.self) private var data
    @StateObject private var viewModel = StatisticsViewModel()

    private var summary: GlobalStatsSummary {
        viewModel.summary(from: data.media)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Periode")
                            .font(.headline)

                        Picker("Periode", selection: $viewModel.selectedPeriod) {
                            ForEach(StatsPeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)

                        if viewModel.selectedPeriod == .custom {
                            VStack(spacing: 12) {
                                DatePicker("Debut", selection: $viewModel.customStartDate, displayedComponents: .date)
                                DatePicker("Fin", selection: $viewModel.customEndDate, displayedComponents: .date)
                            }
                        }

                        Text(viewModel.rangeLabel)
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
}

#Preview {
    StatisticsView()
        .environment(MediaViewModel())
}
