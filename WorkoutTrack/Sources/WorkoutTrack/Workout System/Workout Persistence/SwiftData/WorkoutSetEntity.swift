//
//  WorkoutSet.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import Foundation
import SwiftData

@Model
final class WorkoutSetEntity {
    @Attribute(.unique) var id: UUID
    var reps: Int
    var weight: Double
    
    var isFinished: Bool

    var entry: WorkoutEntryEntity?
    var order: Int

    init(
        id: UUID = UUID(),
        reps: Int,
        weight: Double,
        isFinished: Bool,
        order: Int,
        entry: WorkoutEntryEntity? = nil
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.isFinished = isFinished
        self.order = order
        self.entry = entry
    }
}

extension WorkoutSetEntity {
    convenience init(dto: WorkoutSetDTO) {
        self.init(id: dto.id, reps: dto.reps, weight: dto.weight, isFinished: dto.isFinished, order: dto.order, entry: nil)
    }
    
    var dto: WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
    }
    
    func update(from set: WorkoutSetDTO, in session: ModelContext) {
        self.reps = set.reps
        self.weight = set.weight
        self.isFinished = set.isFinished
        self.order = set.order
    }
}
