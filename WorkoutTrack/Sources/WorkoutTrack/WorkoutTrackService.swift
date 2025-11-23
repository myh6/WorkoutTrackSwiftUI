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
    func getExerciseName(from id: UUID) async throws -> String? {
        return try await exercise.loadExercises(by: .byID(id)).first?.name
    }
    
    func addCustomExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.addExercise(exercise)
    }
    
    func deleteExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.removeExercise(exercise)
        
        let query = QueryBuilder()
            .containsExercises([exercise.id])
            .onlyIncludExercises([exercise.id])
            .build()
        let entries = try await self.workoutTrack.retrieve(query: query).flatMap(\.entries)
        for entry in entries {
            try await self.workoutTrack.delete(entry)
        }
    }
    
    func updateExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.updateExercise(exercise)
    }
}

extension WorkoutTrackService {
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSessionDTO] {
        try await self.workoutTrack.retrieve(query: query)
    }
    
    func addSessions(_ sessions: [WorkoutSessionDTO]) async throws {
        for session in sessions {
            try await self.workoutTrack.insert(session)
        }
    }
    
    func addEntry(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws {
        for entry in entries {
            let existedExercise = try await exercise.loadExercises(by: .byID(entry.exerciseID))
            guard !existedExercise.isEmpty else { continue }
            try await self.workoutTrack.insert([entry], to: session)
        }
    }
    
    func addSets(_ sets: [WorkoutSetDTO], to entry: WorkoutEntryDTO) async throws {
        let query = QueryBuilder()
            .filterEntry([entry.id])
            .build()
        let entry = try await workoutTrack.retrieve(query: query).flatMap(\.entries)
        guard let firstEntry = entry.first else { return }
        try await workoutTrack.insert(sets, to: firstEntry)
    }
}
