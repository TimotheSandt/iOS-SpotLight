//
//  GenreSelectionView.swift
//  SpotLight
//
//  Created by sandt timothe on 25/03/2026.
//

import SwiftUI

struct GenreSelectionView: View {
    let allGenres = Genre.allCases // Assure-toi d'avoir une enum Genre
    
    @Binding var selectedGenres: [Genre]

    var body: some View {
        // Utilisation de FlowLayout ou d'un rendu dynamique
        VStack(alignment: .leading, spacing: 10) {
            Text("Genres")
                .font(.footnote)
            
            // Une approche simple : Flow Layout personnalisé
            FlowLayout(spacing: 8) {
                ForEach(allGenres, id: \.self) { genre in
                    genreChip(for: genre)
                }
            }
        }
    }

    @ViewBuilder
    private func genreChip(for genre: Genre) -> some View {
        let isSelected = selectedGenres.contains(genre)
        
        Text(genre.rawValue)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .onTapGesture {
                if isSelected {
                    selectedGenres.removeAll { $0 == genre }
                } else {
                    selectedGenres.append(genre)
                }
            }
    }
}

#Preview {
    // On simule une liste de genres déjà sélectionnés (ou vide)
    GenreSelectionView(selectedGenres: .constant([.action, .comedy]))
        .padding()
        .background(Color.white)
}
