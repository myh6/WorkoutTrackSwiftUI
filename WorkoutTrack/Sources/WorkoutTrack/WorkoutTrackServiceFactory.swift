//
//  WorkoutTrackServiceFactory.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import Foundation
import SwiftData

public final class WorkoutTrackServiceFactory {
    public enum Storage { case inMemory, persistent }
    
    private let container: ModelContainer
    
    public init(storage: Storage, storeURL: URL? = nil) throws {
        let config: ModelConfiguration = {
            switch storage {
            case .inMemory:
                return ModelConfiguration("WorkoutTrackModel", isStoredInMemoryOnly: true)
            case .persistent:
                if let storeURL {
                    return ModelConfiguration("WorkoutTrackModel", url: storeURL)
                }
                return ModelConfiguration("WorkoutTrackModel")
            }
        }()
        
        self.container = try ModelContainer(
            for: ExerciseEntity.self, WorkoutEntry.self, WorkoutSession.self, WorkoutSet.self,
            configurations: config)
    }
    
    public func makeService() -> WorkoutTrackService {
        let workoutStore = SwiftDataWorkoutSessionStore(modelContainer: container)
        let exerciseStore = SwiftDataExerciseStore(modelContainer: container)
        let exerciseSystem = DefaultExerciseSystem(
            loaders: [PresavedExercisesLoader(), exerciseStore],
            io: exerciseStore)
        
        return WorkoutTrackService(exercise: exerciseSystem, workoutTrack: workoutStore)
    }
}
