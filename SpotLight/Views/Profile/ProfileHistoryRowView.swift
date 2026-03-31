//
//  ProfileHistoryRowView.swift
//  SpotLight
//
//  Created by timothe sandt on 31/03/2026.
//

import SwiftUI

struct ProfileHistoryRowView: View {
    let media: any Media
    let session: WatchSession

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 54, height: 72)

                Image(systemName: media.mediaType == .film ? "film" : "tv")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(media.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(media.mediaType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(session.date.formatted(.dateTime.day().month().year()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(session.status.rawValue)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }
}
