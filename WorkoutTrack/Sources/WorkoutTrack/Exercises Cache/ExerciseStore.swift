//
//  File.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public protocol ExerciseStore {
    func insert(_ exercise: CustomExercise) async throws
    func retrieve() async throws -> [CustomExercise]
    func delete(_ exercise: CustomExercise) async throws
}

public enum ExerciseQuery {
    case all(sort: ExerciseSort?)
    case byID(UUID, sort: ExerciseSort?)
    case byName(String, sort: ExerciseSort?)
    case byCategory(String, sort: ExerciseSort?)
}

public enum ExerciseSort {
    case name(ascending: Bool)
    case category(ascending: Bool)
}
