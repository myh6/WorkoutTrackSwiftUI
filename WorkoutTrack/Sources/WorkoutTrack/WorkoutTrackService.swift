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
            if let sameDaySession = try await getSessionOnSameDay(date: session.date) {
                try await workoutTrack.insert(session.entries, to: sameDaySession)
            } else {
                try await self.workoutTrack.insert(session)
            }
        }
    }
    
    func addEntry(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws {
        for entry in entries {
            let existedExercise = try await exercise.loadExercises(by: .byID(entry.exerciseID))
            guard !existedExercise.isEmpty else { continue }
            
            if let sameExerciseEntry = try await sameExerciseWithin(session: session.id, exercise: entry.exerciseID) {
                try await workoutTrack.insert(entry.sets, to: sameExerciseEntry)
            } else {
                try await workoutTrack.insert([entry], to: session)
            }
        }
    }
    
    func addSets(_ sets: [WorkoutSetDTO], to entry: WorkoutEntryDTO) async throws {
        try await workoutTrack.insert(sets, to: entry)
    }
    
    func updateSession(_ session: WorkoutSessionDTO) async throws {
        try await workoutTrack.update(session)
    }
    
    func updateEntry(_ entry: WorkoutEntryDTO, within session: WorkoutSessionDTO) async throws {
        try await workoutTrack.update(entry, withinSession: session.id)
    }
    
    func deleteSession(_ session: WorkoutSessionDTO) async throws {
        try await workoutTrack.delete(session)
    }
    
    func deleteEntry(_ entry: WorkoutEntryDTO) async throws {
        try await workoutTrack.delete(entry)
    }
    
    func deleteSet(_ set: WorkoutSetDTO) async throws {
        try await workoutTrack.delete(set)
    }
}

extension WorkoutTrackService {
    private func getSessionOnSameDay(date: Date) async throws -> WorkoutSessionDTO? {
        let range = date.startOfDay()...date.endOfDay()
        let query = QueryBuilder()
            .filterDateRange(range)
            .build()
        
        return try await workoutTrack.retrieve(query: query).first
    }
    
    private func sameExerciseWithin(session: UUID, exercise: UUID) async throws -> WorkoutEntryDTO? {
        let query = QueryBuilder()
            .filterSession(session)
            .containsExercises([exercise])
            .build()
        
        return try await workoutTrack
            .retrieve(query: query)
            .flatMap(\.entries)
            .filter { $0.exerciseID == exercise }
            .first
    }
}
