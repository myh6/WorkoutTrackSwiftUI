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
    
    func hasData(_ date: Date) -> Bool {
        return false
    }
    
    func toggleSetFinished(entryID: UUID, setID: UUID) async {
        await mutateSet(entryID: entryID, setID: setID) { $0.updating(isFinished: !$0.isFinished) }
    }
    
    func updateSetReps(entryID: UUID, setID: UUID, reps: Int) async {
        await mutateSet(entryID: entryID, setID: setID) { oldSet in
            guard oldSet.reps != reps else { return nil }
            return oldSet.updating(reps: reps)
        }
    }
    
    func updateSetWeight(entryID: UUID, setID: UUID, weight: Double) async {
        await mutateSet(entryID: entryID, setID: setID) { oldSet in
            guard oldSet.weight != weight else { return nil }
            return oldSet.updating(weight: weight)
        }
    }
    
    func updateSetOrder(entryID: UUID, setID: UUID, order: Int) async {
        await mutateSet(entryID: entryID, setID: setID) { oldSet in
            guard oldSet.order != order else { return nil }
            return oldSet.updating(order: order)
        }
    }
    
    func deleteSet(entryID: UUID, setID: UUID) async {
        guard state != .loading else { return }
        guard let ctx = resolveContext(entryID, setID) else { return }
        do {
            try await service.deleteSet(ctx.set)
            await load()
        } catch {
            state = .failed(String(describing: error))
        }
    }
    
    func updateEntryOrder(_ entryID: UUID, to order: Int) async {
        guard state != .loading else { return }
        guard let (session, entry) = resolveEntryContext(entryID) else { return }
        guard entry.order != order else { return }
        let newEntry = entry.updating(order: order)
        do {
            try await service.updateEntry(newEntry, within: session)
            await load()
        } catch {
            state = .failed(String(describing: error))
        }
    }
    
    func addSet(weight: Double, reps: Int, to entry: UUID) async {
        guard state != .loading else { return }
        guard let ctx = resolveEntryContext(entry) else { return }
        do {
            try await service.addSets([
                createSet(weight: weight, reps: reps)
            ], to: ctx.entry, within: ctx.session.id)
            await load()
        } catch {
            state = .failed(String(describing: error))
        }
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
    private func mutateSet(entryID: UUID, setID: UUID, transform: (WorkoutSet) -> WorkoutSet?) async {
        guard state != .loading else { return }
        guard let ctx = resolveContext(entryID, setID) else { return }
        guard let updatedSet = transform(ctx.set) else { return }
        
        do {
            try await service.updateSet(updatedSet, within: ctx.entry, and: ctx.session.id)
            await load()
        } catch {
            state = .failed(String(describing: error))
        }
    }
    
    private func createSet(weight: Double, reps: Int) -> WorkoutSet {
        WorkoutSet(id: UUID(), reps: reps, weight: weight, isFinished: false, order: 0)
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

final class PreviewService: WorkoutDayServicing {
    private var sessions = [WorkoutSession]()
    private var exerciseDict: [UUID: String] = [:]
    
    init(sessions: [WorkoutSession] = [WorkoutSession](), exerciseDict: [UUID : String]) {
        self.sessions = sessions
        self.exerciseDict = exerciseDict
    }
    
    static func makeSample(selectedDate: Date, calendar: Calendar = .current) -> PreviewService {
        let exerciseA = UUID()
        let exerciseB = UUID()
        
        let entryA = WorkoutEntry(
            id: UUID(),
            exerciseID: exerciseA,
            sets: [
                WorkoutSet(id: UUID(), reps: 8, weight: 50, isFinished: false, order: 0),
                WorkoutSet(id: UUID(), reps: 6, weight: 55, isFinished: true, order: 1)
            ],
            createdAt: selectedDate,
            order: 0
        )
        
        let entryB = WorkoutEntry(
            id: UUID(),
            exerciseID: exerciseB,
            sets: [
                WorkoutSet(id: UUID(), reps: 12, weight: 20, isFinished: false, order: 0)
            ],
            createdAt: selectedDate,
            order: 1
        )
        
        let session = WorkoutSession(
            id: UUID(),
            date: selectedDate,
            entries: [entryA, entryB]
        )
        
        return PreviewService(
            sessions: [session],
            exerciseDict: [
                exerciseA: "Bench Press",
                exerciseB: "Lat Pulldown"
            ]
        )
    }
    
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSession] {
        return sessions
    }
    
    func getExerciseName(from id: UUID) async throws -> String? {
        exerciseDict[id] ?? "Exercise \(id.uuidString.prefix(3))"
    }
    
    func deleteSet(_ set: WorkoutSet) async throws {
        sessions = sessions.map { session in
            let updatedEntries = session.entries.map { entry in
                let newSets = entry.sets.filter { $0.id != set.id }
                return WorkoutEntry(
                    id: entry.id,
                    exerciseID: entry.exerciseID,
                    sets: newSets,
                    createdAt: entry.createdAt,
                    order: entry.order
                )
            }

            return WorkoutSession(
                id: session.id,
                date: session.date,
                entries: updatedEntries
            )
        }
    }
    
    func updateSet(_ set: WorkoutSet, within entry: WorkoutEntry, and session: UUID) async throws {
        sessions = sessions.map { s in
            guard s.id == session else { return s }
            
            let updatedEntries = s.entries.map { e in
                guard e.id == entry.id else { return e }
                let updatedSet = e.sets.map {
                    $0.id == set.id ? set : $0
                }
                
                return WorkoutEntry(id: e.id, exerciseID: e.exerciseID, sets: updatedSet, createdAt: e.createdAt, order: e.order)
            }
            
            return WorkoutSession(id: s.id, date: s.date, entries: updatedEntries)
        }
    }
    
    func updateEntry(_ entry: WorkoutEntry, within session: WorkoutSession) async throws {
    }
    
    func addSets(_ sets: [WorkoutSet], to entry: WorkoutEntry, within sessionID: UUID) async throws {
        sessions = sessions.map { session in
            guard session.id == sessionID else { return session }

            let updatedEntries = session.entries.map { e in
                guard e.id == entry.id else { return e }

                let nextOrder = (e.sets.map(\.order).max() ?? -1) + 1
                let appended = sets.enumerated().map { offset, s in
                    WorkoutSet(
                        id: s.id,
                        reps: s.reps,
                        weight: s.weight,
                        isFinished: s.isFinished,
                        order: nextOrder + offset
                    )
                }

                return WorkoutEntry(
                    id: e.id,
                    exerciseID: e.exerciseID,
                    sets: e.sets + appended,
                    createdAt: e.createdAt,
                    order: e.order
                )
            }

            return WorkoutSession(
                id: session.id,
                date: session.date,
                entries: updatedEntries
            )
        }
    }
}
