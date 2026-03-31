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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Temps de visionnage")
                .font(.headline)

            Chart {
                let dataPoints = stats.chartData(from: data.media)
                let unit = stats.strideUnit
                
                ForEach(dataPoints) { point in
                    BarMark(
                        // On utilise l'unité calculée pour la largeur des barres
                        x: .value("Date", point.date, unit: unit.component),
                        y: .value("Durée", point.duration)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                let unit = stats.strideUnit
                AxisMarks(values: .stride(by: unit.component, count: unit.value)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: axisFormat(for: unit.component))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel("\(value.as(Int.self) ?? 0)m")
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(18)
    }
    
    // Helper pour le formatage des labels de l'axe X
    private func axisFormat(for component: Calendar.Component) -> Date.FormatStyle {
        if component == .month {
            return .dateTime.month(.abbreviated)
        } else {
            return .dateTime.day().month(.abbreviated)
        }
    }
}

#Preview {
    TimeChartView()
        .environment(MediaViewModel())
        .environment(StatisticsViewModel())
}
