//
//  UserExerciseLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public protocol ExerciseLoader {
    func fetchExercises() -> [Exercise]
}
