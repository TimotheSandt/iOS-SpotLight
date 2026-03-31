//
//  ProfileHistoryRowView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileHistoryRowView: View {
    let item: ProfileHistoryItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 54, height: 72)

                Image(systemName: item.subtitle == MediaType.film.rawValue ? "film" : "tv")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(item.watchedDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.watchCountText)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }
}
