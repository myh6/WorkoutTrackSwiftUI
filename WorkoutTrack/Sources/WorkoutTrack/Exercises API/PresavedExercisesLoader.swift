//
//  PresavedExercisesLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/4.
//

import Foundation

struct PresavedExercisesLoader {
    
    func loadExercises(by query: ExerciseQuery) -> [DisplayableExercise] {
        let all: [DisplayableExercise] = PresavedExercises.all
        switch query {
        case .all(let sorting):
            return all.applyCustomSorting(sorting)
        case .byID(let id):
            return all
                .filter { $0.id == id }
        case .byName(let name, let sorting):
            return all
                .filter { $0.name.localizedCaseInsensitiveContains(name) }
                .applyCustomSorting(sorting)
        case .byCategory(let category, let sorting):
            return all
                .filter { $0.rawCategory == category }
                .applyCustomSorting(sorting)
        }
    }
    
}
