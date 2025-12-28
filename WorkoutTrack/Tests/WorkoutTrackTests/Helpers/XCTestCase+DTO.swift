//
//  XCTestCase+DTO.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/8.
//

import XCTest
import WorkoutTrack

extension XCTestCase {
    
    func getPushUpID() -> UUID {
        UUID(uuidString: "5FBF70AE-30AC-F9A2-FF1F-D6A322FE1485")!
    }

    func anySession(id: UUID = UUID(), date: Date = .now, entries: [WorkoutEntry] = []) -> WorkoutSession {
        WorkoutSession(id: id, date: date, entries: entries)
    }
    
    func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSet] = [], createdAt: Date = Date(), order: Int = 0) -> WorkoutEntry {
        WorkoutEntry(id: id, exerciseID: exercise, sets: sets, createdAt: createdAt, order: order)
    }
    
    func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0, isFinished: Bool = false, order: Int = 0) -> WorkoutSet {
        WorkoutSet(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
    }
    
    func anyExercise(id: UUID = UUID(), name: String = "any name", category: BodyCategory = .abs) -> CustomExercise {
        return CustomExercise(id: id, name: name, category: category)
    }
}

extension Array where Element == WorkoutSession {
    func mapToAllEntries() -> [WorkoutEntry] {
        flatMap(\.entries)
    }
    
    func mapToAllSets() -> [WorkoutSet] {
        flatMap(\.entries).flatMap(\.sets)
    }
}

