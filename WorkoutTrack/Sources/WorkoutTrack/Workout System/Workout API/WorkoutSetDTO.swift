//
//  WorkoutSetDTO.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/28.
//

import Foundation

public struct WorkoutSetDTO: Equatable, Identifiable {
    public let id: UUID
    public let reps: Int
    public let weight: Double
    public let isFinished: Bool
    public let order: Int
    
    public init(id: UUID, reps: Int, weight: Double, isFinished: Bool, order: Int) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.isFinished = isFinished
        self.order = order
    }
}

extension Array where Element == WorkoutSetDTO {
    func hasSet(id: UUID) -> Bool {
        return map(\.id).contains(id)
    }
}
