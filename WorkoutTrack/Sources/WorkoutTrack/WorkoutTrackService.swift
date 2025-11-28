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
//MARK: - Exercise
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
//MARK: - Workout Records
extension WorkoutTrackService {
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSessionDTO] {
        try await self.workoutTrack.retrieve(query: query)
    }
    
    func addSessions(_ sessions: [WorkoutSessionDTO]) async throws {
        for session in sessions {
            if let sameDaySession = try await getSessionOnSameDay(date: session.date) {
                try await addEntry(session.entries, to: sameDaySession)
            } else {
                try await self.workoutTrack.insert(session.normalizedSetOrder())
            }
        }
    }
    
    func addEntry(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws {
        for entry in entries {
            let existedExercise = try await exercise.loadExercises(by: .byID(entry.exerciseID))
            guard !existedExercise.isEmpty else { continue }
            
            if let sameExerciseEntry = try await sameExerciseWithin(session: session.id, exercise: entry.exerciseID) {
                try await addSets(entry.sets, to: sameExerciseEntry, within: session.id)
            } else {
                try await workoutTrack.insert([entry.normalizedSetOrder()], to: session)
            }
        }
    }
    
    /// Inserts new sets into the given entry and automaticaly assigns their order based on the existing sets count
    /// The `order` value passed in DTOs is ignored.
    func addSets(_ sets: [WorkoutSetDTO], to entry: WorkoutEntryDTO, within session: UUID) async throws {
        let allSet = try await allSet(within: entry.id, and: session)
        
        let existingsIDs = Set(allSet.map(\.id))
        let newSets = sets.filter { !existingsIDs.contains($0.id) }
        let startingOrder = (allSet.map(\.order).max() ?? -1) + 1
        let orderedSet = assignOrder(to: newSets, startingAt: startingOrder)
        try await workoutTrack.insert(orderedSet, to: entry)
    }
    
    func updateSession(_ session: WorkoutSessionDTO) async throws {
        try await updateSessionMetadataOnly(session)
        for entry in session.entries {
            try await updateEntry(entry, within: session)
        }
    }
    
    func updateEntry(_ entry: WorkoutEntryDTO, within session: WorkoutSessionDTO) async throws {
        let allEntry = try await allEntry(within: session.id)
        print("all entries' exercise ID \(allEntry.count) in session (\(session.id)): \(allEntry.map(\.id))")
        guard allEntry.hasEntry(id: entry.id) else { return }
        if let sameExercise = allEntry.hasExercise(id: entry.exerciseID), sameExercise.id != entry.id {
            throw WorkoutTrackError.duplicateExerciseInSession
        }
        
        try await reorderAndUpdate(existing: allEntry, moving: entry, rerder: reorder) {
            try await workoutTrack.update($0)
        }
    }
    
    func updateSet(_ set: WorkoutSetDTO, within entry: WorkoutEntryDTO, and session: UUID) async throws {
        let allSet = try await allSet(within: entry.id, and: session)
        guard allSet.hasSet(id: set.id) else { return }
        try await reorderAndUpdate(existing: allSet, moving: set, rerder: reorder) {
            try await workoutTrack.update($0)
        }
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
    
    private func updateSessionMetadataOnly(_ new: WorkoutSessionDTO) async throws {
        let query = QueryBuilder()
            .filterSession(new.id)
            .build()
        guard let existing = try await workoutTrack.retrieve(query: query).first else { return }
        let updated = WorkoutSessionDTO(
            id: existing.id,
            date: new.date,
            entries: existing.entries)
        try await workoutTrack.update(updated)
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
    
    private func allEntry(within session: UUID) async throws -> [WorkoutEntryDTO] {
        let query = QueryBuilder()
            .filterSession(session)
            .build()
        let output = try await workoutTrack.retrieve(query: query)
        print("Retrieved session \(session): \(output)")
        return output.flatMap(\.entries)
    }
    
    private func allSet(within entry: UUID, and session: UUID) async throws -> [WorkoutSetDTO] {
        return try await allEntry(within: session)
            .filter { $0.id == entry }
            .flatMap(\.sets)
    }
    
    private func reorderAndUpdate<T: Identifiable>(
        existing: [T],
        moving updated: T,
        rerder: ([T], T) -> [T],
        apply: (T) async throws -> Void
    ) async rethrows {
        let reordered = rerder(existing, updated)
        for item in reordered {
            try await apply(item)
        }
    }
    
    private func reorder<T: Orderable>(_ items: [T], moving updated: T) -> [T] {
        var newItems = items
            .filter { $0.id != updated.id }
            .sorted { $0.order < $1.order }
        
        newItems.insert(updated, at: min(updated.order, newItems.count))
        
        return newItems.enumerated().map { index, item in
            item.reordered(to: index)
        }
    }
    
    private func assignOrder(to sets: [WorkoutSetDTO], startingAt base: Int = 0) -> [WorkoutSetDTO] {
        sets.enumerated().map { offset, set in
            WorkoutSetDTO(
                id: set.id,
                reps: set.reps,
                weight: set.weight,
                isFinished: set.isFinished,
                order: base + offset)
        }
    }
}

enum WorkoutTrackError: Error, Equatable {
    case duplicateExerciseInSession
}
