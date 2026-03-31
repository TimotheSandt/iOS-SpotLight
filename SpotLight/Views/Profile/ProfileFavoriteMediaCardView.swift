//
//  ProfileFavoriteMediaCardView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileFavoriteMediaCardView: View {
    let title: String
    let value: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(value ?? "-")
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }
}
