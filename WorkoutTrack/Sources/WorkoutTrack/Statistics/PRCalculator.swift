//
//  PRCalculator.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/10.
//

import Foundation

public struct PRCalculator {
    public static func maxWeightPR(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> ExerciseRecord? {
        return workouts
            .mapToExerciseRecords(for: exercise)
            .filter { $0.set.isFinished }
            .max(by: { $0.set.weight < $1.set.weight })
    }
    
    public static func maxRepsPR(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> ExerciseRecord? {
        return workouts
            .mapToExerciseRecords(for: exercise)
            .filter { $0.set.isFinished }
            .max(by: { $0.set.reps < $1.set.reps })
    }
}
