//
//  PRCalculatorTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/8.
//

import XCTest
import WorkoutTrack

struct PRCalculator {
    
    func maxWeightPR(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> Int? {
        return nil
    }
}

final class PRCalculatorTests: XCTestCase {
    
    func test_maxWeightPR_returnsNilWhenNoWorkoutData() {
        let pr = PRCalculator().maxWeightPR(for: UUID(), from: [])
        
        XCTAssertNil(pr)
    }
    
    func test_maxWeightPR_returnsNilWhenNoMatchingExercise() {
        let workouts = [anySession(entries: [
            anyEntry(id: UUID(), sets: [
                anySet(weight: 50), anySet(weight: 60)
            ])
        ])]
        
        let pr = PRCalculator().maxWeightPR(for: UUID(), from: workouts)
        
        XCTAssertNil(pr)
    }
    
    private func anySession(id: UUID = UUID(), date: Date = .now, entries: [WorkoutEntryDTO] = []) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: id, date: date, entries: entries)
    }
    
    private func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSetDTO] = [], createdAt: Date = Date(), order: Int = 0) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exercise, sets: sets, createdAt: createdAt, order: order)
    }
    
    private func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0, isFinished: Bool = false, order: Int = 0) -> WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
    }
}
