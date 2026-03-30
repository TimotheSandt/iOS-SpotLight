//
//  formatDuree.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct formatDuree: View {
    let duree: Int
    
    var body: some View {
        let duration_hour: Int = duree / 60
        let duration_minute: Int = duree.remainderReportingOverflow(dividingBy: 60).partialValue
        
        Text("\(duration_hour)h \(duration_minute)min")
            .font(.caption2)
            .bold()
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .padding(8)
    }
}

#Preview {
    formatDuree(duree: 105)
}
