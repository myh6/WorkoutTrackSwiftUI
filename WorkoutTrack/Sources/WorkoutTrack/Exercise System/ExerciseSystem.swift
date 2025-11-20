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
    func updateExercise(_ exercise: CustomExercise) async throws
}

public typealias ExerciseIO = ExerciseInsertion & ExerciseDeletion & ExerciseUpdate
public class DefaultExerciseSystem: ExerciseSystem {
    private let loaders: [ExerciseLoader]
    private let inserter: ExerciseInsertion
    private let deleter: ExerciseDeletion
    private let updater: ExerciseUpdate
    
    public init(loaders: [ExerciseLoader], io: ExerciseIO) {
        self.loaders = loaders
        self.inserter = io
        self.deleter = io
        self.updater = io
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
    
    public func updateExercise(_ exercise: CustomExercise) async throws {
        try await updater.update(exercise)
    }
}
