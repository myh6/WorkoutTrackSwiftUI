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

extension WorkoutEntry: Orderable {
    func reordered(to newOrder: Int) -> WorkoutEntry {
        WorkoutEntry(id: id, exerciseID: exerciseID, sets: sets, createdAt: createdAt, order: newOrder)
    }
}

extension WorkoutSet: Orderable {
    func reordered(to newOrder: Int) -> WorkoutSet {
        WorkoutSet(id: id, reps: reps, weight: weight, isFinished: isFinished, order: newOrder)
    }
}

