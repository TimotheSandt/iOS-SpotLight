//
//  ProfileFavoriteMediaCardView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileFavoriteMediaCardView: View {
    let title: String
    let media: (any Media)?
    let explanation: (any Media) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())

            if let media {
                NavigationLink {
                    MediaDetailView(mediaID: media.id)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(media.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                if media.interaction.isFavorite {
                                    Label("Favori", systemImage: "star.fill")
                                        .font(.caption.bold())
                                        .foregroundStyle(.yellow)
                                }
                            }

                            Text("\(media.creator) • \(media.releaseYear)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(explanation(media))
                                .font(.caption)
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
            } else {
                Text("Aucun favori disponible pour l'instant.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
