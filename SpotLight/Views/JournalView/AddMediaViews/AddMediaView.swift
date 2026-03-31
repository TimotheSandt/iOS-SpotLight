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
    @State var seasons: [SeasonDraft] = []

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
                        selectedGenres: $selectedGenres,
                        seasons: $seasons
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
                            let builtSeasons = seasons.compactMap { season -> Season? in
                                guard
                                    let number = Int(season.number),
                                    let episodeCount = Int(season.episodeCount),
                                    let averageDuration = Int(season.averageDuration),
                                    episodeCount > 0,
                                    averageDuration > 0
                                else {
                                    return nil
                                }

                                return Season(
                                    number: number,
                                    releaseDate: Date(),
                                    episodeCount: episodeCount,
                                    averageDuration: averageDuration
                                )
                            }

                            data.addSerie(title: title, creator: realisateur, annee: Int(annee) ?? 0, duration: 0, releaseYear: Int(annee) ?? 0, pays: pays, platform: platform, genres: selectedGenres, seasons: builtSeasons, status: status, note: n, comment: c, date: d)
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
            .navigationBarTitle("Ajouter Film/Serie", displayMode: .inline)
        }
    }
}

#Preview {
    NavigationStack {
        AddMediaView()
            .environment(MediaViewModel())
    }
}
