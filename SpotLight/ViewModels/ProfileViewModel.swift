//
//  ProfileViewModel.swift
//  SpotLight
//
//  Created by timothe sandt on 31/03/2026.
//

import Foundation

@Observable
class ProfileViewModel {
    var firstName: String = "Timothe"
    var lastName: String = "Sandt"
    var age: Int = 21

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateFirstName(_ firstName: String) {
        self.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateLastName(_ lastName: String) {
        self.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateAge(_ age: Int) {
        self.age = max(1, min(age, 120))
    }

    func updateProfile(firstName: String, lastName: String, age: Int) {
        updateFirstName(firstName)
        updateLastName(lastName)
        updateAge(age)
    }
}
