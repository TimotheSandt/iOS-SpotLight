import SwiftUI

struct MediaCardView: View {
    @Environment(MediaViewModel.self) var data
    let media: any Media

    private var nextEpisodeLabel: String? {
        guard media is Serie,
              let nextEpisode = data.nextEpisodeToWatch(for: media.id) else {
            return nil
        }

        return "S\(nextEpisode.seasonNumber)E\(nextEpisode.episodeNumber)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Image(systemName: media is Film ? "film" : "tv")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }

                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                    startPoint: .bottom,
                    endPoint: .center
                )
                .cornerRadius(20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(media.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("\(media.creator) - \(media.releaseYear)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .overlay(alignment: .topLeading) {
                Text(media is Serie ? "Serie" : "Film")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }
            .frame(height: 180)
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(media.interaction.status.rawValue)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    if let lastDate = media.interaction.lastWatchedDate {
                        Text(lastDate.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

                    if media is Serie {
                        if let nextEpisodeLabel {
                            Button {
                                data.addNextEpisodeSession(for: media.id)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text(nextEpisodeLabel)
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.gradient)
                                        .shadow(color: .black.opacity(0.2), radius: 3)
                                )
                            }
                        }
                    } else if media.interaction.lastWatchedDate == nil {
                        Button {
                            data.addWatchSession(for: media.id, status: .watched, date: Date())
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Vu")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.gradient)
                                    .shadow(color: .black.opacity(0.2), radius: 3)
                            )
                        }
                    }
                }
                .padding(8)
            }
            .frame(height: 180)

            FlowLayout(spacing: 8) {
                ForEach(media.genres, id: \.self) { genre in
                    Text(genre.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            .padding(8)

            HStack {
                if let firstPlatform = media.platforms.first {
                    Text(firstPlatform.rawValue)
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(8)
                }

                Spacer()

                Text("\(formatDuration(media.displayDuration))")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .padding(8)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview("Vu") {
    MediaCardView(media: Film.testData[0])
        .environment(MediaViewModel())
}

#Preview("Non Vu") {
    MediaCardView(media: Film.testData[1])
        .environment(MediaViewModel())
}
