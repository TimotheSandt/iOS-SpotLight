//
//  ProfileEditSheetView.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
//

import SwiftUI

struct ProfileEditSheetView: View {
    @Environment(ProfileViewModel.self) private var profile
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var ageText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    TextField("Prenom", text: $firstName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Nom", text: $lastName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Age", text: $ageText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()

                Button("Enregistrer") {
                    profile.updateProfile(
                        firstName: firstName,
                        lastName: lastName,
                        age: Int(ageText) ?? profile.age
                    )
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                firstName = profile.firstName
                lastName = profile.lastName
                ageText = String(profile.age)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileEditSheetView()
        .environment(ProfileViewModel())
}
