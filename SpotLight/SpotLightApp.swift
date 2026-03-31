//
//  SpotLightApp.swift
//  SpotLight
//
//  Created by sandt timothe on 18/03/2026.
//

import SwiftUI

@main
struct SpotLightApp: App {
    
    let mediaViewModel = MediaViewModel()
    let statsViewModel = StatisticsViewModel()
    let profileViewModel = ProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            GlobalView()
                .environment(mediaViewModel)
                .environment(statsViewModel)
                .environment(profileViewModel)
        }
    }
}
