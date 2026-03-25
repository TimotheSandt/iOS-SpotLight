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
                            MediaCardView(media: item)
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
