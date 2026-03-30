//
//  SimplifyMediaCardView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct SimplifyMediaCardView: View {
    let media: any Media
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 110)
                Image(systemName: media is Film ? "film" : "tv")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(media.title)
                    .font(.title2)
                    .bold()
                
                Text("\(media.creator) • \(String(media.releaseYear))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if (media.mediaType == .serie) {
                    
                }
                if let serie = media as? Serie {
                    Text("\(serie.seasons.count) saison\(serie.seasons.count > 1 ? "s" : "")")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.primary)
                } else if let film = media as? Film {
                    Text(formatDuration(film.displayDuration))
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.primary)
                }
                
                Text(media.pays)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
    }
}

#Preview("Film") {
    SimplifyMediaCardView(media: Film.testData[0])
}

#Preview("Série") {
    SimplifyMediaCardView(media: Serie.testData[0])
}
