//
//  SwiftDataExerciseStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/3.
//

import Foundation
import SwiftData

@ModelActor
final actor SwiftDataExerciseStore: ExerciseStore {
    
    func insert(_ exercise: CustomExercise) throws {
        let entity = ExerciseEntity(id: exercise.id, name: exercise.name, category: exercise.rawCategory.rawValue)
        modelContext.insert(entity)
        try modelContext.save()
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
    
    func delete(_ exercise: CustomExercise) throws {
        let targetId = exercise.id
        let descriptor = FetchDescriptor<ExerciseEntity>(predicate: #Predicate { $0.id == targetId })
        if let entity = try modelContext.fetch(descriptor).first {
            modelContext.delete(entity)
            try modelContext.save()
        }
    }
}
