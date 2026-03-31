//
//  FavoriteMediaRowView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct FavoriteMediaRowView: View {
    let media: any Media

    var body: some View {
        NavigationLink {
            MediaDetailView(mediaID: media.id)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                Text(media.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                    Text("\(media.creator) • \(media.releaseYear)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let note = media.interaction.note {
                        Text(String(format: "%.1f/5", note))
                            .font(.subheadline.bold())
                    }

                    Text("\(media.interaction.watchHistory.count) visionnage\(media.interaction.watchHistory.count > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

