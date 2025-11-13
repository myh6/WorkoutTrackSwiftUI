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
        let result = OneRepMaxCalculator.getBestOneRepMax(for: UUID(), from: [])
        XCTAssertNil(result)
    }
    
    func test_getBestOneRepMax_returnsNilWhenNoMatchingExercise() {
        let result = OneRepMaxCalculator.getBestOneRepMax(for: UUID(), from: [
            anySession(entries: [
                anyEntry(exercise: UUID(), sets: [
                    anySet(reps: 10, weight: 10)
                ])
            ])
        ])
        XCTAssertNil(result)
    }
    
    func test_getBestOneRepMax_returnsMaxRepsFromMatchingExercise() {
        let exerciseID = UUID()
        let workouts = makeWorkoutSession(exerciseID: exerciseID, sets: [
            (10, 30), (10, 10), (10, 60)
        ])
        
        let result = OneRepMaxCalculator.getBestOneRepMax(for: exerciseID, from: [workouts])
        
        XCTAssertEqual(result?.date, workouts.date)
        XCTAssertEqual(result?.oneRepMax, 80.0)
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
