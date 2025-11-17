//
//  DisplayableExercise+Array.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/7.
//

import Foundation

extension Array where Element == DisplayableExercise {
    func applyCustomSorting(_ sorting: ExerciseSort?) -> [Element] {
        return self.sorted(by: sorting?.toComparator() ?? defaultSorting())
    }
    
    private func defaultSorting() -> (DisplayableExercise, DisplayableExercise) -> Bool {
        return { $0.name < $1.name }
    }
}
