//
//  StatisticsView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI


private struct StatsHighlightView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(18)
    }
}

