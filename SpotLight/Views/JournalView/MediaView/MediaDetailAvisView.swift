//
//  MediaDetailAvisView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

import SwiftUI

struct MediaDetailAvisView: View {
    @State var media: any Media
    @State private var isEditing: Bool = false
    
    // États temporaires pour l'édition
    @State private var tempNote: String = ""
    @State private var tempComment: String = ""
    
    var hasAvis: Bool {
        media.interaction.note != nil || (media.interaction.comment != nil && !media.interaction.comment!.isEmpty)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ton avis")
                    .font(.headline)
                Spacer()
                
                // Bouton Edit (visible si pas en wishlist)
                if media.interaction.status != .wishlist {
                    Button(hasAvis ? "Modifier" : "Ajouter") {
                        tempNote = media.interaction.note != nil ? String(Int(media.interaction.note!)) : "0"
                        tempComment = media.interaction.comment ?? ""
                        isEditing = true
                    }
                    .font(.subheadline)
                }
            }
            
            if hasAvis {
                VStack(alignment: .leading, spacing: 10) {
                    // Affichage de la note si elle existe
                    if let note = media.interaction.note {
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= Int(note) ? "star.fill" : "star")
                                    .foregroundStyle(index <= Int(note) ? .yellow : .gray.opacity(0.3))
                                    .font(.caption)
                            }
                            Text("\(Int(note))/5").font(.caption).bold()
                        }
                    }
                    
                    // Affichage du commentaire s'il existe
                    if let comment = media.interaction.comment, !comment.isEmpty {
                        Text(comment)
                            .font(.callout)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.gray.opacity(0.05))
                            .cornerRadius(12)
                    }
                }
            } else {
                Text(media.interaction.status == .wishlist ? "Indisponible en Wishlist" : "Aucun avis pour le moment")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        // SHEET D'ÉDITION
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Note").font(.subheadline).bold()
                        StarRatingView(rating: $tempNote)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Commentaire").font(.subheadline).bold()
                        TextField("Qu'en avez-vous pensé ?", text: $tempComment, axis: .vertical)
                            .lineLimit(5...10)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Mon Avis")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Annuler") { isEditing = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Enregistrer") {
                            media.interaction.note = Double(tempNote)
                            media.interaction.comment = tempComment
                            isEditing = false
                        }
                        .bold()
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}



#Preview("Avec Avis (Inception)") {
    MediaDetailAvisView(media: Film.testData[0])
}

#Preview("Sans Avis (The Bear)") {
    MediaDetailAvisView(media: Serie.testData[0])
}

#Preview("Wishlist (Dune)") {
    MediaDetailAvisView(media: Film.testData[1])
}
