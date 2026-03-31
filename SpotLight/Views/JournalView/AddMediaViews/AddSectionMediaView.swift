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
    @Binding var seasons: [SeasonDraft]

    var body: some View {
        VStack(spacing: 15) {
            Text("Infos du titre")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            var titleHint: String {
                (mediaType == .film) ? "Titre du film" : "Titre de la série"
            }
            TextField("Titre \(titleHint)", text: $title)
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
                TextField("Realisateur", text: $realisateur)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))

                TextField("Annee", text: $annee)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }

            HStack {
                if mediaType == .film {
                    TextField("Duree", text: $duree)
                        .padding(.horizontal)
                        .frame(height: 35)
                        .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }

                TextField("Pays / langue", text: $pays)
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }

            GenreSelectionView(selectedGenres: $selectedGenres)
                .padding(.top, 5)

            if mediaType == .serie {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Saisons")
                            .font(.footnote)
                            .foregroundStyle(.gray)

                        Spacer()

                        Button("Ajouter saison") {
                            seasons.append(SeasonDraft(number: String(seasons.count + 1)))
                        }
                        .font(.caption.weight(.semibold))
                    }

                    if seasons.isEmpty {
                        Text("Ajoute une ou plusieurs saisons avec le nombre d'episodes et la duree moyenne.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach($seasons) { $season in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Saison \(season.number)")
                                    .font(.caption.weight(.semibold))

                                Spacer()

                                Button(role: .destructive) {
                                    let seasonID = season.id
                                    seasons.removeAll { $0.id == seasonID }
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }

                            HStack {
                                TextField("Episodes", text: $season.episodeCount)
                                    .padding(.horizontal)
                                    .frame(height: 35)
                                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                TextField("Duree moyenne (min)", text: $season.averageDuration)
                                    .padding(.horizontal)
                                    .frame(height: 35)
                                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }

                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
            }
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
            mediaType: .constant(.serie),
            platform: .constant(.netflix),
            realisateur: .constant("Christopher Nolan"),
            annee: .constant("2010"),
            duree: .constant("148"),
            pays: .constant("USA"),
            selectedGenres: .constant([.action, .scifi]),
            seasons: .constant([SeasonDraft(number: "1", episodeCount: "8", averageDuration: "42")])
        )
        .padding()
    }
}
