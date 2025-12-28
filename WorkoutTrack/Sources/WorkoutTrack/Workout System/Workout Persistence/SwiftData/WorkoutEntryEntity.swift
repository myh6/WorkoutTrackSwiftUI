//
//  WorkoutEntry.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import Foundation
import SwiftData

@Model
final class WorkoutEntryEntity {
    @Attribute(.unique) var id: UUID
    var exerciseID: UUID

    var session: WorkoutSessionEntity?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSetEntity.entry)
    var sets: [WorkoutSetEntity]
    
    var createdAt: Date
    var order: Int

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        session: WorkoutSessionEntity? = nil,
        sets: [WorkoutSetEntity] = [],
        createdAt: Date,
        order: Int
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.session = session
        self.sets = sets
        self.createdAt = createdAt
        self.order = order
    }
}

extension WorkoutEntryEntity {
    convenience init(dto: WorkoutEntry) {
        self.init(id: dto.id, exerciseID: dto.exerciseID, session: nil, sets: [], createdAt: dto.createdAt, order: dto.order)
        self.sets = dto.sets.map { setDTO in
            let set = WorkoutSetEntity(dto: setDTO)
            set.entry = self
            return set
        }
    }
    
    var dto: WorkoutEntry {
        WorkoutEntry(id: id, exerciseID: exerciseID, sets: sets.map(\.dto).sorted { $0.order < $1.order }, createdAt: createdAt, order: order)
    }
    
    func update(from dto: WorkoutEntry, in context: ModelContext) {
        self.exerciseID = dto.exerciseID
        self.order = dto.order
        self.createdAt = dto.createdAt
        
        sets.forEach { context.delete($0) }
        self.sets = dto.sets.map { setDTO in
            let set = WorkoutSetEntity(dto: setDTO)
            set.entry = self
            return set
        }
    }
}
