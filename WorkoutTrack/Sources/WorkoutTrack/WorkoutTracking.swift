//
//  WorkoutTracking.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/12/23.
//

import Foundation

public protocol WorkoutTracking {

    // MARK: - Exercise
    func getExerciseName(from id: UUID) async throws -> String?
    func addCustomExercise(_ exercise: CustomExercise) async throws
    func deleteExercise(_ exercise: CustomExercise) async throws
    func updateExercise(_ exercise: CustomExercise) async throws
    
    // MARK: - Workout Records
    // MARK: Session
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSession]
    func addSessions(_ sessions: [WorkoutSession]) async throws
    func updateSession(_ session: WorkoutSession) async throws
    func deleteSession(_ session: WorkoutSession) async throws
    
    // MARK: Entry
    func addEntry(_ entries: [WorkoutEntry], to session: WorkoutSession) async throws
    func updateEntry(_ entry: WorkoutEntry, within session: WorkoutSession) async throws
    func deleteEntry(_ entry: WorkoutEntry) async throws

    // MARK: Set
    /// Inserts new sets into the given entry and automaticaly assigns their order based on the existing sets count
    /// The `order` value passed in DTOs is ignored.
    func addSets(_ sets: [WorkoutSet], to entry: WorkoutEntry, within session: UUID) async throws
    func updateSet(_ set: WorkoutSet, within entry: WorkoutEntry, and session: UUID) async throws
    func deleteSet(_ set: WorkoutSet) async throws
}
