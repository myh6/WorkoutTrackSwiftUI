//
//  CustomExercise+Array.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/3.
//

@testable import WorkoutTrack

extension Array where Element == CustomExercise {
    func sortedByNameInAscendingOrder() -> [CustomExercise] {
        sorted { $0.name < $1.name }
    }
    
    func sortedByNameInDescendingOrder() -> [CustomExercise] {
        sorted { $0.name > $1.name }
    }
    
    func sortedByCategoryInAscendingOrder() -> [CustomExercise] {
        sorted { $0.category < $1.category }
    }
    
    func sortedByCategoryInDescendingOrder() -> [CustomExercise] {
        sorted { $0.category > $1.category }
    }
}
