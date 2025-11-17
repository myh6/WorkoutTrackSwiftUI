//
//  Orderable.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/7.
//

import Foundation

protocol Orderable: Identifiable {
    var order: Int { get }
    func reordered(to newOrder: Int) -> Self
}

extension WorkoutEntryDTO: Orderable {
    func reordered(to newOrder: Int) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exerciseID, sets: sets, createdAt: createdAt, order: newOrder)
    }
}

extension WorkoutSetDTO: Orderable {
    func reordered(to newOrder: Int) -> WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight, isFinished: isFinished, order: newOrder)
    }
}

