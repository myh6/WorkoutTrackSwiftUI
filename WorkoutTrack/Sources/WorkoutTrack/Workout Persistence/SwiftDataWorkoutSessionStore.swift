//
//  SwiftDataWorkoutSessionStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/17.
//

import Foundation
import SwiftData

@ModelActor
final actor SwiftDataWorkoutSessionStore {
    
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
        if let postProcess {
            retrieved = postProcess(retrieved)
        }
        return retrieved
    }
    
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
        guard let existing = try getSessionFromContext(id: session.id) else {
            try insert(session)
            try insert(entries, to: session)
            return
        }
        entries.forEach { insert($0, in: existing) }
        try modelContext.save()
    }
    
    func delete(_ session: WorkoutSessionDTO) throws {
        guard let existing = try getSessionFromContext(id: session.id) else { return }
        
        modelContext.delete(existing)
        try modelContext.save()
    }
}

extension SwiftDataWorkoutSessionStore {
    private func getSessionFromContext(id: UUID) throws -> WorkoutSession? {
        let descriptor = FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.id == id })
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
        let predicate = PredicateFactory.getPredicate(query.sessionId, query.dateRange, query.containExercises)
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

extension WorkoutSession {
    func update(from dto: WorkoutSessionDTO, in context: ModelContext) {
        self.date = dto.date
        entries.forEach { context.delete($0) }
        
        self.entries = dto.entries.map { entryDTO in
            let entry = WorkoutEntry(dto: entryDTO)
            entry.session = self
            return entry
        }
    }
}
