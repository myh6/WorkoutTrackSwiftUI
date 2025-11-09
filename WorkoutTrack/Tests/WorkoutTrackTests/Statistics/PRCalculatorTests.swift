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
}
