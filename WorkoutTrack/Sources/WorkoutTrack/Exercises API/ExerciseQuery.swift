//
//  ExerciseQuery.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/6.
//

import Foundation

public enum ExerciseQuery {
    case all(sort: ExerciseSort?)
    case byID(UUID)
    case byName(String, sort: ExerciseSort?)
    case byCategory(BodyCategory, sort: ExerciseSort?)
}

public enum ExerciseSort {
    case name(ascending: Bool)
    case category(ascending: Bool)
}

extension ExerciseSort {
    func toComparator() -> (DisplayableExercise, DisplayableExercise) -> Bool {
        switch self {
        case .name(let ascending):
            return { ascending == true ? $0.name < $1.name : $0.name > $1.name  }
        case .category(let ascending):
            return { ascending == true ? $0.category < $1.category : $0.category > $1.category }
        }
    }
}
