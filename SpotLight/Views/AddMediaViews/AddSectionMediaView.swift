//
//  AddSectionMediaView.swift
//  SpotLight
//
//  Created by sandt timothe on 25/03/2026.
//

import SwiftUI

struct AddSectionMediaView: View {
    
    @Binding var title: String
    @Binding var mediaType: MediaType
    @Binding var platform: Platform
    @Binding var realisateur: String
    @Binding var annee: String
    @Binding var duree: String
    @Binding var pays: String
    @Binding var selectedGenres: [Genre]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Infos du titre")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Titre \((mediaType == .film) ? "du film" : "de la série")", text: $title)
                .padding(.horizontal)
                .frame(height: 35)
                .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            
            Picker("Select platform", selection: $platform) {
                ForEach(Platform.allCases, id: \.self) { pf in
                    Text(pf.rawValue).tag(pf)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .frame(height: 35)
            .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            
            HStack {
                TextField("Réalisateur", text: $realisateur)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                TextField("Année", text: $annee)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            
            HStack {
                TextField("Durée", text: $duree)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                TextField("Pays / langue", text: $pays)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            
            GenreSelectionView(selectedGenres: $selectedGenres)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        AddSectionMediaView(
            title: .constant("Inception"),
            mediaType: .constant(.film),
            platform: .constant(.netflix),
            realisateur: .constant("Christopher Nolan"),
            annee: .constant("2010"),
            duree: .constant("2h28"),
            pays: .constant("USA"),
            selectedGenres: .constant([.action, .scifi])
        )
        .padding()
    }
}
