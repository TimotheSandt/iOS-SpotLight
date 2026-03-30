//
//  MediaDetailHistoriqueView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct MediaDetailHistoriqueView: View {
    
    let media: any Media
    @Binding var showAddInteraction: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Historique")
                    .font(.headline)
                Spacer()
                Button {
                    showAddInteraction = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal)
            
            if media.interaction.watchHistory.isEmpty {
                Text("Aucune session enregistrée")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(media.interaction.watchHistory.sorted(by: { $0.date > $1.date })) { session in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text(session.date.formatted(date: .long, time: .omitted))
                        Spacer()
                        Text(session.status.rawValue)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
}

//#Preview("Film") {
//    SimplifyMediaCardView(media: Film.testData[0], showAddInteraction: .constant(false))
//}
//
//#Preview("Série") {
//    SimplifyMediaCardView(media: Serie.testData[0], showAddInteraction: .constant(false))
//}
