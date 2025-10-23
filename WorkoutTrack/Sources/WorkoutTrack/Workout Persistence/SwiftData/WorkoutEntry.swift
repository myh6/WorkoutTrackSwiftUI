//
//  WorkoutEntry.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import Foundation
import SwiftData

@Model
final class WorkoutEntry {
    @Attribute(.unique) var id: UUID
    var exerciseID: UUID

    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.entry)
    var sets: [WorkoutSet]
    
    var createdAt: Date
    var order: Int

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        session: WorkoutSession? = nil,
        sets: [WorkoutSet] = [],
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

struct WorkoutEntryDTO: Equatable {
    let id: UUID
    let exerciseID: UUID
    let sets: [WorkoutSetDTO]
    let createdAt: Date
    let order: Int
}

extension WorkoutEntry {
    convenience init(dto: WorkoutEntryDTO) {
        self.init(id: dto.id, exerciseID: dto.exerciseID, session: nil, sets: [], createdAt: dto.createdAt, order: dto.order)
        self.sets = dto.sets.map { setDTO in
            let set = WorkoutSet(dto: setDTO)
            set.entry = self
            return set
        }
    }
    
    var dto: WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exerciseID, sets: sets.map(\.dto), createdAt: createdAt, order: order)
    }
}
