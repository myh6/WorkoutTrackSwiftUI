//
//  UserExerciseLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public protocol DisplayableExercise {
    var id: UUID { get }
    var name: String { get }
    var category: String { get }
}

public protocol ExerciseLoader {
    func loadExercises() -> [DisplayableExercise]
}
