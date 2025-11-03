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
        self.sets = assignOrder(to: dto.sets, startingAt: 0)
            .map { setDTO in
                let set = WorkoutSet(dto: setDTO)
                set.entry = self
                return set
            }
    }
    
    var dto: WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exerciseID, sets: sets.map(\.dto).sorted { $0.order < $1.order }, createdAt: createdAt, order: order)
    }
    
    func assignOrder(to sets: [WorkoutSetDTO], startingAt base: Int = 0) -> [WorkoutSetDTO] {
        sets.enumerated().map { offset, set in
            WorkoutSetDTO(
                id: set.id,
                reps: set.reps,
                weight: set.weight,
                isFinished: set.isFinished,
                order: base + offset)
        }
    }
    
    func update(from dto: WorkoutEntryDTO, in context: ModelContext) {
        self.exerciseID = dto.exerciseID
        self.order = dto.order
        self.createdAt = dto.createdAt
        
        sets.forEach { context.delete($0) }
        self.sets = dto.sets.map { setDTO in
            let set = WorkoutSet(dto: setDTO)
            set.entry = self
            return set
        }
    }
}
