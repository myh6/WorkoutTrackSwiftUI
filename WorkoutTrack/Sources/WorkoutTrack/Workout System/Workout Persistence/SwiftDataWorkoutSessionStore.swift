//
//  SwiftDataWorkoutSessionStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/17.
//

import Foundation
import SwiftData

@ModelActor
final actor SwiftDataWorkoutSessionStore: WorkoutSessionStore {
    
    //MARK: - Retrieve
    func retrieve(query: SessionQueryDescriptor?) throws -> [WorkoutSessionDTO] {
        var descriptor = FetchDescriptor<WorkoutSession>()
        let (predicate, sort, postProcess) = translate(query)
        if let predicate {
            descriptor.predicate = predicate
        }
        if !sort.isEmpty {
            descriptor.sortBy = sort
        }
        var retrieved = try modelContext.fetch(descriptor).map(\.dto)
        print("Retrieved in SwiftDataWorkoutSessionStore: \(retrieved)")
        if let postProcess {
            retrieved = postProcess(retrieved)
        }
        return retrieved
    }
    
    //MARK: - Insert
    func insert(_ session: WorkoutSessionDTO) throws {
        if let existing = try getSessionFromContext(id: session.id) {
            existing.update(from: session, in: modelContext)
        } else {
            let model = WorkoutSession(dto: session)
            modelContext.insert(model)
        }
        
        try modelContext.save()
    }
    
    func insert(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) throws {
        guard let existingSession = try getSessionFromContext(id: session.id) else {
            try insert(session)
            try insert(entries, to: session)
            return
        }
        
        entries.forEach { insert($0, in: existingSession) }
        try modelContext.save()
    }
    
    func insert(_ sets: [WorkoutSetDTO], to entry: WorkoutEntryDTO) throws {
        guard let existingEntry = try getEntryFromContext(id: entry.id) else { return }

        sets.forEach { setDTO in
            let set = WorkoutSet(dto: setDTO)
            set.entry = existingEntry
            modelContext.insert(set)
        }
        
        try modelContext.save()
    }
    
    //MARK: - Delete
    func delete(_ session: WorkoutSessionDTO) throws {
        guard let existing = try getSessionFromContext(id: session.id) else { return }
        
        modelContext.delete(existing)
        try modelContext.save()
    }
    
    func delete(_ entry: WorkoutEntryDTO) throws {
        guard let existing = try getEntryFromContext(id: entry.id) else { return }
        
        modelContext.delete(existing)
        try modelContext.save()
    }
    
    func delete(_ set: WorkoutSetDTO) throws {
        guard let existing = try getSetFromContext(id: set.id) else { return }
        
        modelContext.delete(existing)
        try modelContext.save()
    }
    
    //MARK: - Update
    func update(_ session: WorkoutSessionDTO) throws {
        guard let existing = try getSessionFromContext(id: session.id) else { return }
        
        existing.update(from: session, in: modelContext)
        try modelContext.save()
    }
    
    func update(_ entry: WorkoutEntryDTO) throws {
        guard let existing = try getEntryFromContext(id: entry.id) else { return }
        existing.update(from: entry, in: modelContext)
        try modelContext.save()
    }
    
    func update(_ set: WorkoutSetDTO) throws {
        guard let existing = try getSetFromContext(id: set.id) else { return }
        existing.update(from: set, in: modelContext)
        try modelContext.save()
    }
}

extension SwiftDataWorkoutSessionStore {
    private func getSessionFromContext(id: UUID) throws -> WorkoutSession? {
        let descriptor = FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
    
    private func getEntryFromContext(id: UUID) throws -> WorkoutEntry? {
        let descriptor = FetchDescriptor<WorkoutEntry>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
    
    private func getSetFromContext(id: UUID) throws -> WorkoutSet? {
        let descriptor = FetchDescriptor<WorkoutSet>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
    
    private func insert(_ entryDTO: WorkoutEntryDTO, in session: WorkoutSession) {
        let entry = WorkoutEntry(dto: entryDTO)
        entry.session = session
        modelContext.insert(entry)
    }
    
    typealias Process = ([WorkoutSessionDTO]) -> [WorkoutSessionDTO]
    private func translate(_ query: SessionQueryDescriptor?) -> (Predicate<WorkoutSession>?, [SortDescriptor<WorkoutSession>], Process?) {
        guard let query else { return (nil, [], nil) }
        let predicate = PredicateFactory.getPredicate(query.sessionId, query.dateRange)
        let sortDescriptor = getSortDescriptor(query.sortBy)
        let transform = getProcess(query.postProcessing)
        
        return (predicate, sortDescriptor, transform)
    }
    
    private func getSortDescriptor(_ arr: [QuerySort]?) -> [SortDescriptor<WorkoutSession>] {
        guard let arr else { return [] }
        var sortDescriptor: [SortDescriptor<WorkoutSession>] = []
        for sort in arr {
            switch sort {
            case .byId(let ascending):
                sortDescriptor.append(SortDescriptor(\.id, order: ascending ? .forward : .reverse))
            case .byDate(let ascending):
                sortDescriptor.append(SortDescriptor(\.date, order: ascending ? .forward : .reverse))
            default:
                continue
            }
        }
        return sortDescriptor
    }
    
    private func getProcess(_ postProcessing: [PostProcessing]?) -> Process? {
        guard let postProcessing, !postProcessing.isEmpty else { return nil }
        return { session in
            postProcessing.reduce(session) { result, post in
                post.transform(result)
            }
        }
    }
}
