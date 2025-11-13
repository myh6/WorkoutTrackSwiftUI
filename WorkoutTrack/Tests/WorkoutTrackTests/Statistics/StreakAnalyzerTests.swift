//
//  StreakAnalyzerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import XCTest
import WorkoutTrack

struct StreakAnalyzer {
    static func getWorkoutDays(from workouts: [WorkoutSessionDTO]) -> [Date: Bool] {
        return [:]
    }
}

final class StreakAnalyzerTests: XCTestCase {
    
    func test_getWorkoutDays_returnsEmptyWhenNoWorkout() {
        let result = StreakAnalyzer.getWorkoutDays(from: [])
        XCTAssertTrue(result.isEmpty)
    }
}
