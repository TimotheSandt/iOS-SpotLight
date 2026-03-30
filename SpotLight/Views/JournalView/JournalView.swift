//
//  JournalView.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import SwiftUI

struct JournalView: View {
    
    @State private var selectedStatus: Status = Status.all
    
    @Environment(MediaViewModel.self) var data
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    func isStatusCorrect(_ status: Status, for item: any Media) -> Bool {
        if status == .all {
            return true
        }
        
        switch status {
            case .wishlist:
                return item.interaction.isWishlisted
            case .watched:
                return item.interaction.isWatched
            case .watching:
                return item.interaction.isWatching
            case .abandoned:
                return item.interaction.isAbandoned
            default:
                return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Picker("Select status", selection: $selectedStatus) {
                        ForEach(Status.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("filter")
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(data.media, id: \.id) { item in
                            if (isStatusCorrect(selectedStatus, for: item)) {
                                // Rendre la carte cliquable
                                NavigationLink {
                                    MediaDetailView(mediaID: item.id)
                                } label: {
                                    MediaCardView(media: item)
                                        .contentShape(Rectangle()) // Améliore la zone de clic
                                }
                                .buttonStyle(PlainButtonStyle()) // Évite que le texte devienne tout bleu
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .listStyle(.plain)
                .navigationBarTitle("SpotLight")
                .navigationDestination(for: Bool.self) {_ in
                    AddMediaView()
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: true) {
                            Text("Add")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    JournalView()
        .environment(MediaViewModel())
}
