//
//  StarRatingView.swift
//  SpotLight
//
//  Created by sandt timothe on 30/03/2026.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: String
    var maxRating = 5
    
    // État local pour l'animation de rebond
    @State private var tappedStar: Int? = nil

    private var currentRating: Int {
        Int(rating) ?? 0
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= currentRating ? "star.fill" : "star")
                    .foregroundStyle(index <= currentRating ? .yellow : .gray.opacity(0.4))
                    .font(.title2)
                    // Effet de rebond : s'agrandit si c'est l'étoile cliquée
                    .scaleEffect(tappedStar == index ? 1.5 : 1.0)
                    .onTapGesture {
                        updateRating(index)
                    }
            }
        }
    }

    private func updateRating(_ index: Int) {
        // 1. Retour haptique (vibration)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // 2. Animation de rebond
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
            tappedStar = index
            rating = String(index)
        }

        // 3. Réinitialisation de l'échelle après un court délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                tappedStar = nil
            }
        }
    }
}

#Preview {
    StarRatingView(rating: .constant("3"))
}
