//
//  AddMediaView.swift
//  SpotLight
//
//  Created by sandt timothe on 25/03/2026.
//

import SwiftUI

struct AddMediaView: View {

    @Environment(MediaViewModel.self) var data
    @Environment(\.dismiss) var dismiss
    
    @State private var mediaType: MediaType = .film
    @State private var platform: Platform = .netflix
    @State private var selectedGenres: [Genre] = []
    
    
    @State var title: String = ""
    @State var realisateur: String = ""
    @State var annee: String = ""
    @State var duree: String = ""
    @State var pays: String = ""
    
    @State var note: String = ""
    @State var commentaire: String = ""
    @State var status: Status = .watched
    @State var date: Date = Date()
    

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Select media type", selection: $mediaType) {
                        ForEach(MediaType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    AddSectionMediaView(
                        title: $title,
                        mediaType: $mediaType,
                        platform: $platform,
                        realisateur: $realisateur,
                        annee: $annee,
                        duree: $duree,
                        pays: $pays,
                        selectedGenres: $selectedGenres
                    )
                    
                    AddSectionSuiviView(
                        note: $note,
                        commentaire: $commentaire,
                        status: $status,
                        date: $date
                    )
                    
                    Spacer()
                    
                    Button {
                        let d: Date? = (status == .wishlist) ? nil : date
                        let n: Double? = (status == .wishlist) ? nil : Double(note)
                        let c: String? = (status == .wishlist) ? nil : commentaire
                        
                        if mediaType == .film {
                            data.addFilm(title: title, creator: realisateur, annee: Int(annee) ?? 0, duration: Int(duree) ?? 0, releaseYear: Int(annee) ?? 0, pays: pays, platform: platform, genres: selectedGenres, status: status, note: n, comment: c, date: d)
                        } else {
                            data.addSerie(title: title, creator: realisateur, annee: Int(annee) ?? 0, duration: Int(duree) ?? 0, releaseYear: Int(annee) ?? 0, pays: pays, platform: platform, genres: selectedGenres, seasons: [], status: status, note: n, comment: c, date: d)
                        }
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Ajouter Film/Série", displayMode: .inline)
        }
    }
}

#Preview {
    NavigationStack {
        AddMediaView()
            .environment(MediaViewModel())
    }
}
