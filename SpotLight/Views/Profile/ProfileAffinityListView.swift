//
//  ProfileAffinityListView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileAffinityListView: View {
    let title: String
    let items: [(label: String, count: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())

            if items.isEmpty {
                Text("Pas encore assez de visionnages.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.label) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.label)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.count)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }

                        GeometryReader { geometry in
                            let maxCount = max(items.map(\.count).max() ?? 1, 1)
                            let width = geometry.size.width * CGFloat(item.count) / CGFloat(maxCount)

                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.15))
                                Capsule()
                                    .fill(Color.blue.gradient)
                                    .frame(width: max(width, 10))
                            }
                        }
                        .frame(height: 10)
                    }
                }
            }
        }
    }
}
