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
        
    }
}

//MARK: - Entry
extension SwiftDataWorkoutSessionStore {
    func retrieveEntry() throws -> [WorkoutEntryDTO] {
        return []
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
