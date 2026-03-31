//
//  StatisticsView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI


private enum TypeChart: String, CaseIterable, Codable {
    case genre = "Genre"
    case platforme = "Plateform"
}

struct StatisticsView: View {

    @Environment(MediaViewModel.self) private var data
    @Environment(StatisticsViewModel.self) private var stats
    
    @State private var typeChart: TypeChart = .genre

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
                    
                    TimeChartView()

                    
                    Picker("Select type chart", selection: $typeChart) {
                        ForEach(TypeChart.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    ScrollView(.horizontal){
                        LazyHStack(spacing: 16) {
                            
                            MediaPieChartView(title: typeChart.rawValue, data: (typeChart == .genre) ? stats.rankedGenres(from: data.media) : stats.rankedPlatforms(from: data.media))
                                .frame(width: 300, height: 300)
                            RatingChartView(title: typeChart.rawValue, data: (typeChart == .genre) ? stats.avgRatingGenres(from: data.media) : stats.avgRatingPlateform(from: data.media))
                                .frame(width: 300, height: 300)
                        }
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
