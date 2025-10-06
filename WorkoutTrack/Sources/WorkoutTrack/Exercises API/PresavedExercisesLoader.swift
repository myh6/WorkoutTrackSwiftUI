//
//  PresavedExercisesLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/4.
//

import Foundation

struct PresavedExercisesLoader: ExerciseLoader {
    
    func loadExercises() -> [DisplayableExercise] {
        return PresavedExercises.all
    }
}
