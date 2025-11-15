//
//  XCTestCase+DTO.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/8.
//

import XCTest
import WorkoutTrack

extension XCTestCase {
    func anySession(id: UUID = UUID(), date: Date = .now, entries: [WorkoutEntryDTO] = []) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: id, date: date, entries: entries)
    }
    
    func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSetDTO] = [], createdAt: Date = Date(), order: Int = 0) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exercise, sets: sets, createdAt: createdAt, order: order)
    }
    
    func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0, isFinished: Bool = false, order: Int = 0) -> WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
    }
}
