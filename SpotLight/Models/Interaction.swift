//
//  Interaction.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//



import Foundation

struct WatchSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var status: Status
}



struct MediaInteraction: Identifiable, Codable {
    var id = UUID()
    var status: Status = .wishlist
    
    var note: Double?
    var comment: String?
    
    var watchHistory: [WatchSession] = []
    var isFavorite: Bool = false
    
    
    
    
    
    var isWatched: Bool {
        !watchHistory.isEmpty || status == .watched
    }
    
    var lastWatchedDate: Date? {
        watchHistory.map { $0.date }.max()
    }
}
