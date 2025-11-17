//
//  ExerciseSystem.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/17.
//
import Foundation

public protocol ExerciseSystem {
    func loadExercises(by query: ExerciseQuery) async throws -> [any DisplayableExercise]
    func addExercise(_ exercise: CustomExercise) async throws
    func removeExercise(_ exercise: CustomExercise) async throws
}

public class DefaultExerciseSystem: ExerciseSystem {
    private let loaders: [ExerciseLoader]
    private let inserter: ExerciseInsertion
    private let deleter: ExerciseDeletion
    
    public init(loaders: [ExerciseLoader], inserter: ExerciseInsertion, deleter: ExerciseDeletion) {
        self.loaders = loaders
        self.inserter = inserter
        self.deleter = deleter
    }
    
    public func loadExercises(by query: ExerciseQuery) async throws -> [any DisplayableExercise] {
        var loaded: [any DisplayableExercise] = []
        
        for loader in loaders {
            let output = try await loader.loadExercises(by: query)
            loaded.append(contentsOf: output)
        }
        
        return loaded
    }
    
    public func addExercise(_ exercise: CustomExercise) async throws {
        try await inserter.insert(exercise)
    }
    
    public func removeExercise(_ exercise: CustomExercise) async throws {
        try await deleter.delete(exercise)
    }
}
