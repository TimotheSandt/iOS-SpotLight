//
//  MediaView.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import SwiftUI

struct MediaCardView: View {
    
    let media: any Media

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Illustration + Informations superposées
            ZStack(alignment: .bottomLeading) {
                
                // Fond de l'illustration
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Image(systemName: media is Film ? "film" : "tv")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                
                // 2. Dégradé de protection pour le texte
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                               startPoint: .bottom,
                               endPoint: .center)
                    .cornerRadius(20)

                // Main information (titre, créateur, date)
                VStack(alignment: .leading, spacing: 2) {
                    Text(media.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(media.creator) • \(media.releaseYear)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                
            }
            .overlay(alignment: .topLeading) {
                // Film ou Serie
                Text(media is Serie ? "Serie" : "Film")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }
            .frame(height: 180)
            .overlay(alignment: .topTrailing) {
                // Statut et Date à droite
                VStack(alignment: .trailing, spacing: 4) {
                    Text(media.interaction.status.rawValue).font(.caption2)
                        .bold()
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    if let lastDate = media.interaction.lastWatchedDate {
                        Text(lastDate.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .padding(8)
            }
            .frame(height: 180)
            
            // Genres
            FlowLayout(spacing: 8) {
                ForEach (media.genres, id: \.self) { genre in
                    Text(genre.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            .padding(8)
            
            HStack {
                // Plateforme
                if let firstPlatform = media.platforms.first {
                    Text(firstPlatform.rawValue)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(8)
                }
                
                Spacer()
                
                Text("\(formatDuration(media.displayDuration))")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .padding(8)
            }
            
            
            
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview("Film") {
    MediaCardView(media: Film.testData[0])
}

#Preview("Serie") {
    MediaCardView(media: Serie.testData[0])
}
