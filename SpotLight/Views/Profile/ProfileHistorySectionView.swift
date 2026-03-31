//
//  ProfileHistorySectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileHistorySectionView: View {
    @Environment(MediaViewModel.self) private var data
    @Environment(StatisticsViewModel.self) private var stats

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Derniers visionnages")
                .font(.headline)

            if data.recentMedia().isEmpty {
                Text("Aucun visionnage pour le moment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(data.recentMedia(), id: \.id) { item in
                    NavigationLink {
                        MediaDetailView(mediaID: item.id)
                    } label: {
                        ProfileHistoryRowView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}
