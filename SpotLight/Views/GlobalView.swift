//
//  GlobalView.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import SwiftUI

struct GlobalView: View {
    var body: some View {
        TabView {
            Tab("Journal", systemImage: "book") {
                JournalView()
            }
            Tab("Statistiques", systemImage: "chart.bar") {
                StatisticsView()
            }
            Tab("Profil", systemImage: "person") {
                EmptyView()
            }
        }
    }
}

#Preview {
    GlobalView()
        .environment(MediaViewModel())
} 
