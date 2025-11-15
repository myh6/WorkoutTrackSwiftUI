//
//  WorkoutSession.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var date: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutEntry.session)
    var entries: [WorkoutEntry]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        entries: [WorkoutEntry] = []
    ) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

public struct WorkoutSessionDTO: Equatable {
    public let id: UUID
    public let date: Date
    public let entries: [WorkoutEntryDTO]
    
    public init(id: UUID, date: Date, entries: [WorkoutEntryDTO]) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}


extension WorkoutSession {
    convenience init(dto: WorkoutSessionDTO) {
        self.init(id: dto.id, date: dto.date, entries: [])
        self.entries = dto.entries.map { entryDTO in
            let entry = WorkoutEntry(dto: entryDTO)
            entry.session = self
            return entry
        }
    }
    
    var dto: WorkoutSessionDTO {
        WorkoutSessionDTO(id: id, date: date, entries: entries
            .map(\.dto)
            .sorted(by: sortByCreatedAtThenCustomThenUUID)
        )
    }
    
    private func sortByCreatedAtThenCustomThenUUID(_ entry1: WorkoutEntryDTO, _ entry2: WorkoutEntryDTO) -> Bool {
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
