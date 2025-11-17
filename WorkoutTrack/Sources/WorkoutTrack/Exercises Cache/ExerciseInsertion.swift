//
//  ExerciseInsertion.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public protocol ExerciseInsertion {
    func insert(_ exercise: CustomExercise) async throws
}

public protocol ExerciseDeletion {
    func delete(_ exercise: CustomExercise) async throws
}
