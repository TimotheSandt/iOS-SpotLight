//
//  MediaPieChartView.swift
//  SpotLight
//
//  Created by sandt timothe on 31/03/2026.
//

import SwiftUI
import Charts

struct MediaPieChartView: View {
    let title: String
    let data: [(label: String, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            Chart(data, id: \.label) { item in
                SectorMark(
                    angle: .value("Sessions", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5 
                )
                .foregroundStyle(by: .value("Catégorie", item.label))
                .annotation(position: .overlay) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 250)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
