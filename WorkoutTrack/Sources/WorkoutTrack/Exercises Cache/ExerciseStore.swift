//
//  File.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import Foundation

public protocol ExerciseStore {
    func retrieve() -> [LocalizedExercise]
}
