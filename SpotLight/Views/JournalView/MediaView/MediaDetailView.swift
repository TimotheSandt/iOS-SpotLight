//
//  MediaDetailView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct MediaDetailView: View {
    
    @State var media: any Media
    @State private var showAddInteraction = false
    @State private var newStatus: Status = .watched
    @State private var newDate: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SimplifyMediaCardView(media: media)

                if media.interaction.status != .wishlist {
                    // AVIS
                    MediaDetailAvisView(media: media)
                    
                    // HISTORIQUE
                    MediaDetailHistoriqueView(media: media, showAddInteraction: $showAddInteraction)
                }
            }
            .padding(.vertical)
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
                    let session = WatchSession(date: newDate, status: newStatus)
                    media.interaction.watchHistory.append(session)
                    media.interaction.status = newStatus
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


#Preview("Détail Film") {
    NavigationStack {
        MediaDetailView(media: Film.testData[0])
    }
}

#Preview("Détail Série (En cours)") {
    let tempSerie = Serie.testData[0]
    var interaction = MediaInteraction(status: .watching)
    interaction.watchHistory = [WatchSession(date: Date(), status: .watching)]
    
    var serieWithHistory = tempSerie
    serieWithHistory.interaction = interaction
    
    return NavigationStack {
        MediaDetailView(media: serieWithHistory)
    }
}
