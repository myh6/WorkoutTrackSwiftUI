//
//  PresavedExercisesLoader.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/4.
//

import Foundation

struct PresavedExercisesLoader {
    
    func loadExercises(by query: ExerciseQuery) -> [DisplayableExercise] {
        let all = PresavedExercises.all
        switch query {
        case .all(let sorting):
            return all.sorted(by: (sorting?.toComparator() ?? defaultSorting()))
        case .byID(let id):
            return all
                .filter { $0.id == id }
        case .byName(let name, let sorting):
            return all
                .filter { $0.name.localizedCaseInsensitiveContains(name) }
                .sorted(by: sorting?.toComparator() ?? defaultSorting())
        default:
            return all
        }
    }
    
    private func defaultSorting() -> (DisplayableExercise, DisplayableExercise) -> Bool {
        return { $0.name < $1.name }
    }
    
}
