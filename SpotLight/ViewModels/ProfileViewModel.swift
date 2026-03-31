//
//  ProfileViewModel.swift
//  SpotLight
//
//  Created by Codex on 31/03/2026.
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
}
