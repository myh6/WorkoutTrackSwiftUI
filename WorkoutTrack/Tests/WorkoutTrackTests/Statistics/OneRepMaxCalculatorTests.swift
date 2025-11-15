//
//  OneRepMaxCalculatorTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import XCTest
import WorkoutTrack

final class OneRepMaxCalculatorTests: XCTestCase {
    
    func test_getBestOneRepMax_returnsNilWhenNoData() {
        let result = OneRepMaxCalculator().getBestOneRepMax(for: UUID(), from: [])
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getBestOneRepMax_returnsNilWhenNoMatchingExercise() {
        let result = OneRepMaxCalculator().getBestOneRepMax(for: UUID(), from: [
            anySession(entries: [
                anyEntry(exercise: UUID(), sets: [
                    anySet(reps: 10, weight: 10)
                ])
            ])
        ])
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getBestOneRepMax_returnsMaxRepsFromMatchingExercise() throws {
        let exerciseID = UUID()
        let workouts = makeWorkoutSession(exerciseID: exerciseID, sets: [
            (10, 30), (10, 10), (10, 60)
        ])
        
        let result = try XCTUnwrap(OneRepMaxCalculator().getBestOneRepMax(for: exerciseID, from: [workouts]).first)
        
        
        XCTAssertEqual(result, OneRepMaxRecord(date: workouts.date, oneRepMax: 80.0))
    }
    
    func test_getBestOneRepMax_returnsBestAcrossMultipleSessions() throws {
        let exerciseID = UUID()
        let today = Date()
        let session1 = makeWorkoutSession(date: today.adding(days: -1), exerciseID: exerciseID, sets: [(5, 50)]) // 1 RM = 58.33
        let session2 = makeWorkoutSession(date: today, exerciseID: exerciseID, sets: [(2, 70)]) // 1 RM = 74.66
        
        let result = OneRepMaxCalculator().getBestOneRepMax(for: exerciseID, from: [session1, session2])
        
        XCTAssertEqual(result.count, 2)
        
        let first = try XCTUnwrap(result.first)
        XCTAssertEqual(first, OneRepMaxRecord(date: session1.date, oneRepMax: 58.33))
        let last = try XCTUnwrap(result.last)
        XCTAssertEqual(last, OneRepMaxRecord(date: session2.date, oneRepMax: 74.67))
    }
    
    //MARK: - Helpers
    private func makeWorkoutSession(
        date: Date = .now,
        exerciseID: UUID,
        sets: [(reps: Int, weight: Double)]
    ) -> WorkoutSessionDTO {
        let dummySet = [
            anySet(reps: 10, weight: 10, isFinished: false),
            anySet(reps: 3, weight: 30, isFinished: false),
            anySet(reps: 5, weight: 20, isFinished: false),
        ] // Should be ignored
        let entry = anyEntry(
            exercise: exerciseID,
            sets: sets.enumerated().map { index, set in
                WorkoutSetDTO(
                    id: UUID(),
                    reps: set.reps,
                    weight: set.weight,
                    isFinished: true,
                    order: index
                )
            } + dummySet)
        return WorkoutSessionDTO(
            id: UUID(),
            date: date,
            entries: [entry]
        )
    }
    
}
