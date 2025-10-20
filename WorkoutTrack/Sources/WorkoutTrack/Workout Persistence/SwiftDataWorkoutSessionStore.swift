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
        let (_, sort, _) = translate(query)
        if !sort.isEmpty {
            descriptor.sortBy = sort
        }
        return try modelContext.fetch(descriptor).map(\.dto)
    }
    
    func retrieveSession(_ query: SessionQuery) throws -> [WorkoutSessionDTO] {
        var descriptor = FetchDescriptor<WorkoutSession>()
        if let predicate = query.predicate {
            descriptor.predicate = predicate
        }
        if let sort = query.sortDescriptor {
            descriptor.sortBy = [sort]
        }
        return try modelContext.fetch(descriptor).map(\.dto)
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

//MARK: - Entry
extension SwiftDataWorkoutSessionStore {
    func retrieveEntry(_ query: EntryQuery) throws -> [WorkoutEntryDTO] {
        var descriptor = FetchDescriptor<WorkoutEntry>()
        if let predicate = query.predicate {
            descriptor.predicate = predicate
        }
        if let sort = query.sortDescriptor {
            descriptor.sortBy = [sort]
        }
        return try modelContext.fetch(descriptor).map(\.dto)
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
    
    private func translate(_ query: SessionQueryDescriptor?) -> (Predicate<WorkoutSession>?, [SortDescriptor<WorkoutSession>], Any?) {
        guard let query else { return (nil, [], nil) }
        
        let sortDescriptor = getSortDescriptor(query.sortBy)
        
        return (nil, sortDescriptor, nil)
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
            }
        }
        return sortDescriptor
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

extension SessionQuery {
    var predicate: Predicate<WorkoutSession>? {
        switch self {
        case .all:
            return nil
        case .sessionID(id: let id):
            return #Predicate { $0.id == id }
        }
    }
    
    var sort: SessionSort? {
        switch self {
        case .all(let sort):
            return sort
        case .sessionID:
            return nil
        }
    }
    
    var sortDescriptor: SortDescriptor<WorkoutSession>? {
        switch self.sort {
        case .bySessionId(let ascending):
            return SortDescriptor(\.id, order: ascending ? .forward : .reverse)
        case .byDate(let ascending):
            return SortDescriptor(\.date, order: ascending ? .forward : .reverse)
        case .none:
            return nil
        }
    }
}

extension EntryQuery {
    var predicate: Predicate<WorkoutEntry>? {
        switch self {
        case .all:
            return nil
        }
    }
    
    var sort: EntrySort? {
        switch self {
        case .all(let sort):
            return sort
        }
    }
    
    var sortDescriptor: SortDescriptor<WorkoutEntry>? {
        switch self.sort {
        case .byId(let ascending):
            return SortDescriptor(\.id, order: ascending ? .forward : .reverse)
        case .byDate(let ascending):
            return SortDescriptor<WorkoutEntry>(\.session?.date, order: ascending ? .forward : .reverse)
        case .none:
            return nil
        }
    }
}
