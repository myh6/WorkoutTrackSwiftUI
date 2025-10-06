//
//  ExerciseQuery.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/6.
//

import Foundation

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
