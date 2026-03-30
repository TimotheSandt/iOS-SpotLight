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
    
    
    
    var isWishlisted: Bool {
        status == .wishlist && watchHistory.isEmpty
    }
    
    var isWatched: Bool {
        if !watchHistory.isEmpty {
            for session in watchHistory {
                if session.status == .watched {
                    return true
                }
            }
        }
        return false
    }
    
    var isWatching: Bool {
        !watchHistory.isEmpty && status == .watching
    }
    
    var isAbandoned: Bool {
        !isWishlisted && !isWatched && !isWatching
    }
    
    
    
    var lastWatchedDate: Date? {
        watchHistory.map { $0.date }.max()
    }
}
