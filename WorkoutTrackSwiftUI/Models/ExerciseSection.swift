//
//  ExerciseSection.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/24.
//

import Foundation
import WorkoutTrack

struct ExerciseSection: Equatable, Identifiable {
    let id: UUID
    let title: String
    let sets: [SetRow]
    let isExpanded: Bool
}

struct SetRow: Equatable, Identifiable {
    let id: UUID
    let reps: Int
    let weight: Double
    let isFinished: Bool
    let order: Int
}
