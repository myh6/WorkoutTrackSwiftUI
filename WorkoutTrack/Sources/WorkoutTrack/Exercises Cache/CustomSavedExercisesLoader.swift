//
//  CustomSavedExercisesLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public class CustomSavedExercisesLoader {
    private let store: ExerciseStore
    
    public init(store: ExerciseStore) {
        self.store = store
    }
}

//MARK: - Load
extension CustomSavedExercisesLoader {
    public func loadExercises() async throws -> [CustomExercise] {
        return try await store.retrieve()
    }
}

//MARK: - Save
extension CustomSavedExercisesLoader {
    public func save(_ exercise: CustomExercise) async throws {
        try await store.insert(exercise)
    }
}

//MARK: - Remove
extension CustomSavedExercisesLoader {
    public func remove(_ exercise: CustomExercise) async throws {
        try await store.delete(exercise)
    }
}
