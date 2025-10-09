//
//  WorkoutSet.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import Foundation
import SwiftData

@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var reps: Int
    var weight: Double

    var entry: WorkoutEntry?

    init(
        id: UUID = UUID(),
        reps: Int,
        weight: Double,
        entry: WorkoutEntry? = nil
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.entry = entry
    }
}

struct WorkoutSetDTO {
    let id: UUID
    let reps: Int
    let weight: Double
}

extension WorkoutSet {
    convenience init(dto: WorkoutSetDTO) {
        self.init(id: dto.id, reps: dto.reps, weight: dto.weight, entry: nil)
    }
}
