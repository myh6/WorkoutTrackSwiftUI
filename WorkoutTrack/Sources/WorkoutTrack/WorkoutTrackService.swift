//
//  WorkoutTrackService.swift
//  WorkoutTrack
//
// Created by Min-Yang Huang on 2025/11/19
//

import Foundation

class WorkoutTrackService {
    private let exercise: ExerciseSystem
    private let workoutTrack: WorkoutSessionStore
    
    init(exercise: ExerciseSystem, workoutTrack: WorkoutSessionStore) {
        self.exercise = exercise
        self.workoutTrack = workoutTrack
    }
}

extension WorkoutTrackService {
    func addCustomExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.addExercise(exercise)
    }
    
    func deleteExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.removeExercise(exercise)
    }
    
    func updateExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.updateExercise(exercise)
    }
}

extension WorkoutTrackService {
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSessionDTO] {
        try await self.workoutTrack.retrieve(query: query)
    }
    
    func addEntry(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws {
        for entry in entries {
            let existedExercise = try await exercise.loadExercises(by: .byID(entry.exerciseID))
            guard !existedExercise.isEmpty else { return }
            try await self.workoutTrack.insert([entry], to: session)
        }
    }
}
