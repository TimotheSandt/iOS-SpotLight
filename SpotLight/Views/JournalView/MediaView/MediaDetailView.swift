import SwiftUI

struct MediaDetailView: View {
    @Environment(MediaViewModel.self) private var data
    let mediaID: UUID
    @State private var showAddInteraction = false
    @State private var newStatus: Status = .watched
    @State private var newDate: Date = Date()
    @State private var selectedSeasonNumber: Int = 1
    @State private var selectedEpisodeNumber: Int = 1

    private var media: (any Media)? {
        data.media(withID: mediaID)
    }

    var body: some View {
        Group {
            if let media {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SimplifyMediaCardView(media: media)
                        if media.interaction.isWatched {
                            Button {
                                data.toggleFavorite(for: mediaID)
                            } label: {
                                Label(
                                    media.interaction.isFavorite ? "Retirer des favoris" : "Definir comme favori",
                                    systemImage: media.interaction.isFavorite ? "star.slash" : "star.fill"
                                )
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(media.interaction.isFavorite ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.12))
                                .foregroundStyle(media.interaction.isFavorite ? .yellow : .blue)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal)
                        }
                        MediaDetailAvisView(mediaID: mediaID)
                        MediaDetailHistoriqueView(media: media, showAddInteraction: $showAddInteraction)
                    }
                    .padding(.vertical)
                }
            } else {
                ContentUnavailableView("Media introuvable", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Details")
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
                        .datePickerStyle(.graphical)

                    if let serie = media as? Serie, !serie.seasons.isEmpty {
                        Picker("Saison", selection: $selectedSeasonNumber) {
                            ForEach(serie.seasons.sorted(by: { $0.number < $1.number })) { season in
                                Text("Saison \(season.number)").tag(season.number)
                            }
                        }
                        .pickerStyle(.menu)

                        if let season = serie.season(number: selectedSeasonNumber) {
                            Picker("Episode", selection: $selectedEpisodeNumber) {
                                ForEach(1...season.episodeCount, id: \.self) { episode in
                                    Text("Episode \(episode)").tag(episode)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(15)

                Button {
                    if media is Serie {
                        data.addWatchSession(
                            for: mediaID,
                            status: newStatus,
                            date: newDate,
                            seasonNumber: selectedSeasonNumber,
                            episodeNumber: selectedEpisodeNumber
                        )
                    } else {
                        data.addWatchSession(for: mediaID, status: newStatus, date: newDate)
                    }
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
            .presentationDetents([.fraction(0.8)])
            .presentationDragIndicator(.visible)
            .onAppear {
                if let nextEpisode = data.nextEpisodeToWatch(for: mediaID) {
                    selectedSeasonNumber = nextEpisode.seasonNumber
                    selectedEpisodeNumber = nextEpisode.episodeNumber
                }
            }
            .onChange(of: selectedSeasonNumber) { _, newValue in
                guard let serie = media as? Serie,
                      let season = serie.season(number: newValue) else {
                    return
                }

                if selectedEpisodeNumber > season.episodeCount {
                    selectedEpisodeNumber = season.episodeCount
                }
                if selectedEpisodeNumber < 1 {
                    selectedEpisodeNumber = 1
                }
            }
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

