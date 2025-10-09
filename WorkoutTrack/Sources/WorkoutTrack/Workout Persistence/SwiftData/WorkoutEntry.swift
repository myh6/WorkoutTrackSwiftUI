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

    init(
        id: UUID = UUID(),
        exerciseID: UUID,
        session: WorkoutSession? = nil,
        sets: [WorkoutSet] = []
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.session = session
        self.sets = sets
    }
}

struct WorkoutEntryDTO: Equatable {
    let id: UUID
    let exerciseID: UUID
    let sets: [WorkoutSetDTO]
}

extension WorkoutEntry {
    convenience init(dto: WorkoutEntryDTO) {
        self.init(id: dto.id, exerciseID: dto.exerciseID, session: nil, sets: [])
        self.sets = dto.sets.map { setDTO in
            let set = WorkoutSet(dto: setDTO)
            set.entry = self
            return set
        }
    }
}
