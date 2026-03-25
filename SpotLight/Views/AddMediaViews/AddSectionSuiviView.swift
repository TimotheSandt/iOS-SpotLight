//
//  AddSectionSuiviView.swift
//  SpotLight
//
//  Created by sandt timothe on 25/03/2026.
//

import SwiftUI

struct AddSectionSuiviView: View {
    @Binding var note: String
    @Binding var commentaire: String
    @Binding var status: Status
    @Binding var date: Date
    
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Suivi")
                .font(.footnote)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("Select status", selection: $status) {
                Text(Status.wishlist.rawValue).tag(Status.wishlist)
                Text(Status.watched.rawValue).tag(Status.watched)
            }
            .pickerStyle(.segmented)
            
            
            if (status != .wishlist) {
                TextField("Note /5", text: $note)  // TODO: transformer en systeme d'étoile
                    .padding(.horizontal)
                    .frame(height: 35)
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .tint(.blue)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .frame(height: 35)
                .frame(maxWidth: .infinity)
                .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                
                TextField("Commentaire", text: $commentaire, axis: .vertical)
                    .lineLimit(4, reservesSpace: true) 
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview("Vu") {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        AddSectionSuiviView(
            note: .constant("5"),
            commentaire: .constant(""),
            status: .constant(.watched),
            date: .constant(Date())
        )
        .padding()
    }
}

#Preview("Wishlist") {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        AddSectionSuiviView(
            note: .constant(""),
            commentaire: .constant(""),
            status: .constant(.wishlist),
            date: .constant(Date())
        )
        .padding()
    }
}
