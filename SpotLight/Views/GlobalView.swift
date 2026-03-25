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
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }

            EmptyView()
                .tabItem {
                    Label("Statistiques", systemImage: "chart.bar")
                }

            EmptyView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
    }
}

#Preview {
    GlobalView()
        .environment(MediaViewModel())
} 
