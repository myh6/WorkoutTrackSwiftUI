//
//  WorkoutSession.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import Foundation
import SwiftData

@Model
final class WorkoutSessionEntity {
    @Attribute(.unique) var id: UUID
    var date: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntryEntity.session)
    var entries: [WorkoutEntryEntity]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        entries: [WorkoutEntryEntity] = []
    ) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

extension WorkoutSessionEntity {
    convenience init(dto: WorkoutSession) {
        self.init(id: dto.id, date: dto.date, entries: [])
        self.entries = dto.entries.map { entryDTO in
            let entry = WorkoutEntryEntity(dto: entryDTO)
            entry.session = self
            return entry
        }
    }
    
    var dto: WorkoutSession {
        WorkoutSession(id: id, date: date, entries: entries
            .map(\.dto)
            .sorted(by: sortByCreatedAtThenCustomThenUUID)
        )
    }
    
    private func sortByCreatedAtThenCustomThenUUID(_ entry1: WorkoutEntry, _ entry2: WorkoutEntry) -> Bool {
        if entry1.createdAt != entry2.createdAt {
            return entry1.createdAt < entry2.createdAt
        } else {
            if entry1.order != entry2.order {
                return entry1.order < entry2.order
            } else {
                return entry1.id < entry2.id
            }
        }
    }
    
    func update(from dto: WorkoutSession, in context: ModelContext) {
        self.date = dto.date
        entries.forEach { context.delete($0) }
        
        self.entries = dto.entries.map { entryDTO in
            let entry = WorkoutEntryEntity(dto: entryDTO)
            entry.session = self
            return entry
        }
    }
}
