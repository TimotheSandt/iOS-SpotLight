import Foundation

struct SeasonDraft: Identifiable, Hashable {
    let id: UUID
    var number: String
    var episodeCount: String
    var averageDuration: String

    init(
        id: UUID = UUID(),
        number: String = "",
        episodeCount: String = "",
        averageDuration: String = ""
    ) {
        self.id = id
        self.number = number
        self.episodeCount = episodeCount
        self.averageDuration = averageDuration
    }
}
