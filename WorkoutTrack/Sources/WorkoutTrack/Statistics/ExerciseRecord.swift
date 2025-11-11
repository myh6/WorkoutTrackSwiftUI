//
//  ExerciseRecord.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/10.
//

import Foundation

public struct ExerciseRecord {
    public let session: WorkoutSessionDTO
    public let entry: WorkoutEntryDTO
    public let set: WorkoutSetDTO
}

extension Array where Element == WorkoutSessionDTO {
    func mapToExerciseRecords(for exercise: UUID) -> [ExerciseRecord] {
        self.flatMap { session in
            session.entries
                .filter { $0.exerciseID == exercise }
                .flatMap { entry in
                    entry.sets.map { ExerciseRecord(session: session, entry: entry, set: $0) }
                }
        }
    }
}
