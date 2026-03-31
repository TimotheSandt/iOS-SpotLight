//
//  RatingChartView.swift
//  SpotLight
//
//  Created by sandt timothe on 31/03/2026.
//



import SwiftUI
import Charts

struct RatingChartView: View {
    let title: String
    let data: [(label: String, rating: Double)]
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notes moyennes par \(title)")
                .font(.headline)
            
            Chart(data, id: \.label) { item in
                BarMark(
                    x: .value("Note", item.rating),
                    y: .value("Genre", item.label)
                )
                .foregroundStyle(.orange.gradient)
                .cornerRadius(4)
                
                .annotation(position: .trailing) {
                    Text(String(format: "%.1f", item.rating))
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                }
            }
            .chartXScale(domain: 0...5)
            .chartXAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}
