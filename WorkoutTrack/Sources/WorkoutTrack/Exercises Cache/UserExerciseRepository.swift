//
//  UserExerciseRepository.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/6/25.
//

import Foundation

public protocol UserExerciseRepository {
    func fetchExercises() -> [Exercise]
}
