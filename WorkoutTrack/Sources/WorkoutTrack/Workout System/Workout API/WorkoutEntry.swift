//
//  WorkoutEntry.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/28.
//

import Foundation

// DTO
public struct WorkoutEntry: Equatable, Identifiable {
    public let id: UUID
    public let exerciseID: UUID
    public let sets: [WorkoutSet]
    public let createdAt: Date
    public let order: Int
    
    public init(id: UUID, exerciseID: UUID, sets: [WorkoutSet], createdAt: Date, order: Int) {
        self.id = id
        self.exerciseID = exerciseID
        self.sets = sets
        self.createdAt = createdAt
        self.order = order
    }
}

extension WorkoutEntry {
    private func withSets(_ sets: [WorkoutSet]) -> WorkoutEntry {
        WorkoutEntry(id: self.id, exerciseID: self.exerciseID, sets: sets, createdAt: self.createdAt, order: self.order)
    }
    
    func normalizedSetOrder() -> WorkoutEntry {
        let normalizedSets = sets.enumerated().map { index, set in
            WorkoutSet(id: set.id,
                          reps: set.reps,
                          weight: set.weight,
                          isFinished: set.isFinished,
                          order: index)
        }
        return withSets(normalizedSets)
    }
}

extension Array where Element == WorkoutEntry {
    func hasEntry(id: UUID) -> Bool {
        return map(\.id).contains(id)
    }
    
    func hasExercise(id: UUID) -> WorkoutEntry? {
        return filter({ $0.exerciseID == id }).first
    }
}

