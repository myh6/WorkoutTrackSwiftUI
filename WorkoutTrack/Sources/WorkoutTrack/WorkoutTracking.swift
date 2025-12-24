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
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSessionDTO]
    func addSessions(_ sessions: [WorkoutSessionDTO]) async throws
    func updateSession(_ session: WorkoutSessionDTO) async throws
    func deleteSession(_ session: WorkoutSessionDTO) async throws
    
    // MARK: Entry
    func addEntry(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws
    func updateEntry(_ entry: WorkoutEntryDTO, within session: WorkoutSessionDTO) async throws
    func deleteEntry(_ entry: WorkoutEntryDTO) async throws

    // MARK: Set
    /// Inserts new sets into the given entry and automaticaly assigns their order based on the existing sets count
    /// The `order` value passed in DTOs is ignored.
    func addSets(_ sets: [WorkoutSetDTO], to entry: WorkoutEntryDTO, within session: UUID) async throws
    func updateSet(_ set: WorkoutSetDTO, within entry: WorkoutEntryDTO, and session: UUID) async throws
    func deleteSet(_ set: WorkoutSetDTO) async throws
}
