//
//  GenreSelectionView.swift
//  SpotLight
//
//  Created by sandt timothe on 25/03/2026.
//

import SwiftUI

struct GenreSelectionView: View {
    let allGenres = Genre.allCases
    
    @Binding var selectedGenres: [Genre]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Genres")
                .font(.footnote)
            
            FlowLayout(spacing: 8) {
                ForEach(allGenres, id: \.self) { genre in
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
        }
    }
}

#Preview {
    GenreSelectionView(selectedGenres: .constant([.action, .comedy]))
        .padding()
        .background(Color.white)
}
