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

struct WorkoutSessionDTO {
    let id: UUID
    let date: Date
    let entries: [WorkoutEntryDTO]
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
}
