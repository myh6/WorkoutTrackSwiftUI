//
//  StreakAnalyzerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import XCTest
import WorkoutTrack

struct StreakAnalyzer {
    static func getWorkoutDays(from workouts: [WorkoutSessionDTO], calendar: Calendar = .current) -> [Date: Bool] {
        var result: [Date: Bool] = [:]
        
        for session in workouts {
            let day = calendar.startOfDay(for: session.date)
            result[day] = true
        }
        
        return result
    }
}

final class StreakAnalyzerTests: XCTestCase {
    
    func test_getWorkoutDays_returnsEmptyWhenNoWorkout() {
        let result = StreakAnalyzer.getWorkoutDays(from: [])
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getWorkoutDays_returnsCorrectValuesByDateForSessionsOnDistinctDays() {
        let calendar = Calendar(identifier: .gregorian)
        let day1 = Date().adding(days: -2)
        let day2 = Date().adding(days: -1)
        let day3 = Date()
        
        let session = [
            anySession(date: day1),
            anySession(date: day2),
            anySession(date: day3),
            anySession(date: day1)
        ]
        
        let result = StreakAnalyzer.getWorkoutDays(from: session, calendar: calendar)
        XCTAssertEqual(result, [
            calendar.startOfDay(for: day1): true,
            calendar.startOfDay(for: day2): true,
            calendar.startOfDay(for: day3): true
        ])
    }
}
