//
//  ModelsData.swift
//  french
//
//  Created by Anton on 01/07/2025.
//

import SwiftUI

// Модели данных
struct VerbConjugation {
    let moods: [MoodConjugation] // Все наклонения глагола
}

struct MoodConjugation: Identifiable {
    let id = UUID() // Уникальный идентификатор
    let name: String // Название наклонения
    let tenses: [TenseConjugation] // Все времена в этом наклонении
}

struct TenseConjugation: Identifiable {
    let id = UUID() // Уникальный идентификатор
    let name: String // Название времени
    let forms: [ConjugationForm] // Все формы спряжения для этого времени
}
