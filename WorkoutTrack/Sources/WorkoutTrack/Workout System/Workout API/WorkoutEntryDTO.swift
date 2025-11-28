//
//  WorkoutEntryDTO.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/28.
//

import Foundation

public struct WorkoutEntryDTO: Equatable, Identifiable {
    public let id: UUID
    public let exerciseID: UUID
    public let sets: [WorkoutSetDTO]
    public let createdAt: Date
    public let order: Int
    
    public init(id: UUID, exerciseID: UUID, sets: [WorkoutSetDTO], createdAt: Date, order: Int) {
        self.id = id
        self.exerciseID = exerciseID
        self.sets = sets
        self.createdAt = createdAt
        self.order = order
    }
}

extension WorkoutEntryDTO {
    private func withSets(_ sets: [WorkoutSetDTO]) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: self.id, exerciseID: self.exerciseID, sets: sets, createdAt: self.createdAt, order: self.order)
    }
    
    func normalizedSetOrder() -> WorkoutEntryDTO {
        let normalizedSets = sets.enumerated().map { index, set in
            WorkoutSetDTO(id: set.id,
                          reps: set.reps,
                          weight: set.weight,
                          isFinished: set.isFinished,
                          order: index)
        }
        return withSets(normalizedSets)
    }
}

extension Array where Element == WorkoutEntryDTO {
    func hasEntry(id: UUID) -> Bool {
        return map(\.id).contains(id)
    }
    
    func hasExercise(id: UUID) -> WorkoutEntryDTO? {
        return filter({ $0.exerciseID == id }).first
    }
}

