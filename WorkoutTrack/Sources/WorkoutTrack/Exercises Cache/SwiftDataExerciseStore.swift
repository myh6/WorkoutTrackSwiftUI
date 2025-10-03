//
//  SwiftDataExerciseStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/3.
//

import Foundation
import SwiftData

@ModelActor
final actor SwiftDataExerciseStore {
    
    func insert(_ exercise: CustomExercise) {
        let entity = ExerciseEntity(id: exercise.id, name: exercise.name, category: exercise.category)
        modelContext.insert(entity)
    }
    
    func retrieve(by query: ExerciseQuery) throws -> [CustomExercise] {
        var descriptor = FetchDescriptor<ExerciseEntity>()
        if let predicate = query.predicate {
            descriptor.predicate = predicate
        }
        
        if let sort = query.sortDescriptor {
            descriptor.sortBy = [sort]
        } else {
            descriptor.sortBy = [SortDescriptor(\.name, order: .forward)]
        }
        
        return try modelContext.fetch(descriptor).toModels()
    }
    
    func delete(_ exercise: CustomExercise) {
        
    }
}
