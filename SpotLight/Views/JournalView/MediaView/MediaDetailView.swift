//
//  MediaDetailView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct MediaDetailView: View {
    
    @Environment(MediaViewModel.self) private var data
    let mediaID: UUID
    @State private var showAddInteraction = false
    @State private var newStatus: Status = .watched
    @State private var newDate: Date = Date()

    private var media: (any Media)? {
        data.media(withID: mediaID)
    }
    
    var body: some View {
        Group {
            if let media {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SimplifyMediaCardView(media: media)
                        MediaDetailAvisView(mediaID: mediaID)
                        MediaDetailHistoriqueView(media: media, showAddInteraction: $showAddInteraction)
                    }
                    .padding(.vertical)
                }
            } else {
                ContentUnavailableView("Media introuvable", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(isPresented: $showAddInteraction) {
            VStack(spacing: 25) {
                Text("Ajouter un visionnage")
                    .font(.headline)
                    .padding(.top)

                VStack(spacing: 20) {
                    Picker("Statut", selection: $newStatus) {
                        ForEach(Status.allCases.filter { $0 != .all && $0 != .wishlist }, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Date", selection: $newDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.graphical) // Plus élégant dans une popup
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(15)

                Button {
                    data.addWatchSession(for: mediaID, status: newStatus, date: newDate)
                    showAddInteraction = false
                } label: {
                    Text("Confirmer")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .presentationDetents([.fraction(0.8)]) // S'ouvre à moitié d'écran
            .presentationDragIndicator(.visible)
        }
    }
}


#Preview("Avec Avis (Inception)") {
    MediaDetailView(mediaID: Film.testData[0].id)
        .environment(MediaViewModel())
}

#Preview("Sans Avis (The Bear)") {
    MediaDetailView(mediaID: Serie.testData[0].id)
        .environment(MediaViewModel())
}

#Preview("Wishlist (Dune)") {
    MediaDetailView(mediaID: Film.testData[1].id)
        .environment(MediaViewModel())
}
