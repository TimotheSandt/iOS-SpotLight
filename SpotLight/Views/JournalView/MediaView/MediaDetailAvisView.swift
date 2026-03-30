//
//  MediaDetailAvisView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct MediaDetailAvisView: View {
    let media: any Media
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ton avis")
                .font(.headline)
            
            HStack {
                if let note = media.interaction.note {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(note) ? "star.fill" : "star")
                                .foregroundStyle(index <= Int(note) ? .yellow : .gray.opacity(0.3))
                        }
                    }
                    Text("\(Int(note))/5")
                        .font(.subheadline).bold()
                }
            }
            
            if let comment = media.interaction.comment, !comment.isEmpty {
                Text(comment)
                    .font(.callout)
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.gray.opacity(0.05))
                    .cornerRadius(12)
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
