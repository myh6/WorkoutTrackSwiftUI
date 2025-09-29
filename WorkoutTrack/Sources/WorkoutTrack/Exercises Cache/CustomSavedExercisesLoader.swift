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
    
    public func getAllExercises() -> [CustomExercise] {
        return store.retrieve()
    }
}

extension CustomSavedExercisesLoader {
    public func save(_ exercise: CustomExercise) throws {
        try store.insert(exercise)
    }
}
