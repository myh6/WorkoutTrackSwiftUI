//
//  CustomSavedExercisesLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public class CustomSavedExercisesLoader {
    private let repository: ExerciseLoader
    
    public init(repository: ExerciseLoader) {
        self.repository = repository
    }
    
    public func getAllExercises() -> [Exercise] {
        return repository.fetchExercises()
    }
}
