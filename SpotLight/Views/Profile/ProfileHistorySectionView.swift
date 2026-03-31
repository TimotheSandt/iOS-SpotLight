//
//  ProfileHistorySectionView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileHistorySectionView: View {
    let recentMedia: [any Media]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Derniers visionnages")
                .font(.headline)

            if recentMedia.isEmpty {
                Text("Aucun visionnage pour le moment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(recentMedia, id: \.id) { media in
                    NavigationLink {
                        MediaDetailView(mediaID: media.id)
                    } label: {
                        ProfileHistoryRowView(media: media)
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
