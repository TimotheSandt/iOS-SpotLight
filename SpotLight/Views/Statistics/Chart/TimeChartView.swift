//
//  TimeChartView.swift
//  SpotLight
//
//  Created by sandt timothe on 31/03/2026.
//

import SwiftUI
import Charts

struct TimeChartView: View {
    @Environment(MediaViewModel.self) private var data
    @Environment(StatisticsViewModel.self) private var stats

    private var dataPoints: [ChartData] {
        stats.chartData(from: data.media)
    }

    private var configuration: ChartConfiguration {
        stats.chartConfiguration
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Temps de visionnage")
                .font(.headline)

            if dataPoints.isEmpty {
                ContentUnavailableView(
                    "Aucune donnee",
                    systemImage: "chart.bar.xaxis",
                    description: Text("Ajoutez des sessions dans la periode selectionnee pour afficher le graphique.")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(dataPoints) { point in
                        BarMark(
                            xStart: .value("Debut", point.startDate),
                            xEnd: .value("Fin", point.endDate),
                            y: .value("Duree", point.duration)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: configuration.component, count: configuration.bucketSize)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: axisFormat)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel("\(value.as(Int.self) ?? 0)m")
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(18)
    }

    private var axisFormat: Date.FormatStyle {
        if configuration.component == .month {
            return .dateTime.month(.abbreviated)
        }
        return .dateTime.day().month(.abbreviated)
    }
}

#Preview {
    TimeChartView()
        .environment(MediaViewModel())
        .environment(StatisticsViewModel())
}
