//
//  WorkoutDayViewModel.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import Foundation
import WorkoutTrack

@MainActor
class WorkoutDayViewModel: ObservableObject {
    
    @Published private(set) var selectedDate: Date
    private let service: WorkoutDayServicing
    private let calendar: Calendar
        
    enum State: Equatable {
        case idle, empty, loading, loaded([ExerciseSection]), failed(String)
    }
    
    @Published private(set) var state: State = .idle
    @Published private(set) var sections: [ExerciseSection] = []
    private var domainSessions: [WorkoutSession] = []
    
    private var cachedName: [UUID: String] = [:]
    
    @Published private(set) var expandedEntryIDs: Set<UUID> = []
    init(selectedDate: Date,
         service: WorkoutDayServicing,
         calendar: Calendar) {
        self.selectedDate = selectedDate
        self.service = service
        self.calendar = calendar
    }
    
    func load() async {
        state = .loading
        let query = QueryBuilder()
            .filterDateRange(selectedDate.dayRange(in: calendar))
            .build()
        do {
            domainSessions = try await service.retrieveSessions(by: query)
            remapSession()
            await prefetchNames()
        } catch {
            state = .failed(String(describing: error))
        }
    }
    
    func toggleSetFinished(entryID: UUID, setID: UUID) async throws {
        try await mutateSet(entryID: entryID, setID: setID) { $0.updating(isFinished: !$0.isFinished) }
    }
    
    func updateSetReps(entryID: UUID, setID: UUID, reps: Int) async throws {
        try await mutateSet(entryID: entryID, setID: setID) { oldSet in
            guard oldSet.reps != reps else { return nil }
            return oldSet.updating(reps: reps)
        }
    }
    
    func updateSetWeight(entryID: UUID, setID: UUID, weight: Double) async throws {
        try await mutateSet(entryID: entryID, setID: setID) { oldSet in
            guard oldSet.weight != weight else { return nil }
            return oldSet.updating(weight: weight)
        }
    }
    
    func updateSetOrder(entryID: UUID, setID: UUID, order: Int) async throws {
        try await mutateSet(entryID: entryID, setID: setID) { oldSet in
            guard oldSet.order != order else { return nil }
            return oldSet.updating(order: order)
        }
    }
    
    func deleteSet(entryID: UUID, setID: UUID) async throws {
        guard state != .loading else { return }
        guard let ctx = resolveContext(entryID, setID) else { return }
        try await service.deleteSet(ctx.set)
        await load()
    }
    
    func updateEntryOrder(_ entryID: UUID, to order: Int) async throws {
        guard state != .loading else { return }
        guard let (session, entry) = resolveEntryContext(entryID) else { return }
        guard entry.order != order else { return }
        let newEntry = entry.updating(order: order)
        try await service.updateEntry(newEntry, within: session)
        await load()
    }
    
    func addSet(weight: Double, reps: Int, to entry: UUID) async throws {
        guard let ctx = resolveEntryContext(entry) else { return }
    }
    
    func selectDate(_ newDate: Date) async {
        guard newDate != selectedDate else { return }
        selectedDate = newDate
        expandedEntryIDs.removeAll()
        domainSessions.removeAll()
        sections.removeAll()
        await load()
    }
    
    func toggleExpanded(entryID: UUID) {
        guard state != .loading else { return }
        if expandedEntryIDs.contains(entryID) {
            expandedEntryIDs.remove(entryID)
        } else {
            expandedEntryIDs.insert(entryID)
        }
        remapSession()
    }
}

extension WorkoutDayViewModel {
    private func remapSession() {
        let cache = cachedName
        sections = WorkoutDayMapper.sections(from: domainSessions, expandedEntryIDs: expandedEntryIDs, nameForExerciseID: { cache[$0] })
        state = sections.isEmpty ? .empty : .loaded(sections)
    }
    
    private func prefetchNames() async {
        let ids = Set(domainSessions.flatMap(\.entries).map(\.exerciseID))
        let missing = ids.filter { cachedName[$0] == nil }
        guard !missing.isEmpty else { return }
        
        for id in missing {
            if let name = try? await service.getExerciseName(from: id) {
                cachedName[id] = name
            }
        }
        
        remapSession()
    }
    
    /// Used to update set's property
    /// - Parameters:
    ///   - transform: If no change need to be made, return nil to stop the update call
    private func mutateSet(entryID: UUID, setID: UUID, transform: (WorkoutSet) -> WorkoutSet?) async throws {
        guard state != .loading else { return }
        guard let ctx = resolveContext(entryID, setID) else { return }
        guard let updatedSet = transform(ctx.set) else { return }
        
        try await service.updateSet(updatedSet, within: ctx.entry, and: ctx.session.id)
        await load()
    }
    
    private func resolveContext(_ entryID: UUID, _ setID: UUID) -> (session: WorkoutSession, entry: WorkoutEntry, set: WorkoutSet)? {
        for session in domainSessions {
            guard let entry = session.entries.first(where: { $0.id == entryID }) else { continue }
            guard let set = entry.sets.first(where: { $0.id == setID }) else { continue }
            return (session, entry, set)
        }
        return nil
    }
    
    private func resolveEntryContext(_ entryID: UUID) -> (session: WorkoutSession, entry: WorkoutEntry)? {
        for session in domainSessions {
            guard let entry = session.entries.first(where: { $0.id == entryID }) else { continue }
            return (session, entry)
        }
        return nil
    }
}

extension WorkoutSet {
    func updating(
        reps: Int? = nil,
        weight: Double? = nil,
        isFinished: Bool? = nil,
        order: Int? = nil
    ) -> WorkoutSet {
        WorkoutSet(id: id, reps: reps ?? self.reps, weight: weight ?? self.weight, isFinished: isFinished ?? self.isFinished, order: order ?? self.order)
    }
}


extension WorkoutEntry {
    func updating(order: Int) -> WorkoutEntry {
        WorkoutEntry(id: id, exerciseID: exerciseID, sets: sets, createdAt: createdAt, order: order)
    }
}
