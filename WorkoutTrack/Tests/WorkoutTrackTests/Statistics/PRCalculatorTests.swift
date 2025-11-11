//
//  PRCalculatorTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/8.
//

import XCTest
import WorkoutTrack

struct ExerciseRecord {
    let session: WorkoutSessionDTO
    let entry: WorkoutEntryDTO
    let set: WorkoutSetDTO
}

extension Array where Element == WorkoutSessionDTO {
    func mapToExerciseRecords(for exercise: UUID) -> [ExerciseRecord] {
        self.flatMap { session in
            session.entries
                .filter { $0.exerciseID == exercise }
                .flatMap { entry in
                    entry.sets.map { ExerciseRecord(session: session, entry: entry, set: $0) }
                }
        }
    }
}

struct PRCalculator {
    static func maxWeightPR(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> ExerciseRecord? {
        return workouts
            .mapToExerciseRecords(for: exercise)
            .filter { $0.set.isFinished }
            .max(by: { $0.set.weight < $1.set.weight })
    }
    
    static func maxRepsPR(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> ExerciseRecord? {
        return workouts
            .mapToExerciseRecords(for: exercise)
            .filter { $0.set.isFinished }
            .max(by: { $0.set.reps < $1.set.reps })
    }
}

final class PRCalculatorTests: XCTestCase {
    
    func test_maxWeightPR_returnsNilWhenNoWorkoutData() {
        let pr = PRCalculator.maxWeightPR(for: UUID(), from: [])
        
        XCTAssertNil(pr)
    }
    
    func test_maxWeightPR_returnsNilWhenNoMatchingExercise() {
        let workouts = [anySession(entries: [
            anyEntry(id: UUID(), sets: [
                anySet(weight: 50), anySet(weight: 60)
            ])
        ])]
        
        let pr = PRCalculator.maxWeightPR(for: UUID(), from: workouts)
        
        XCTAssertNil(pr)
    }
    
    func test_maxWeightPR_returnsMaxWeightFromMatchingExerciseThatHasFinished() throws {
        let exerciseId = UUID()
        let prSet = anySet(weight: 20, isFinished: true)
        let prEntry = anyEntry(exercise: exerciseId, sets: [anySet(weight: 10, isFinished: true), prSet])
        let prSession = anySession(entries: [prEntry])
        let workouts = [
            prSession,
            anySession(entries: [
                anyEntry(
                    exercise: exerciseId,
                    sets: [anySet(weight: 5), anySet(weight: 40, isFinished: false)])])
        ]
        
        let pr = try XCTUnwrap(PRCalculator.maxWeightPR(for: exerciseId, from: workouts))
        
        XCTAssertEqual(pr.session, prSession)
        XCTAssertEqual(pr.entry, prEntry)
        XCTAssertEqual(pr.set, prSet)
    }
    
    func test_maxRepsPR_returnsNilWhenNoWorkoutData() {
        let pr = PRCalculator.maxRepsPR(for: UUID(), from: [])
        
        XCTAssertNil(pr)
    }
    
    func test_maxRepsPR_returnsNilWhenNoMatchingExercise() {
        let workouts = [anySession(entries: [
            anyEntry(id: UUID(), sets: [
                anySet(weight: 50), anySet(weight: 60)
            ])
        ])]
        
        let pr = PRCalculator.maxRepsPR(for: UUID(), from: workouts)
        
        XCTAssertNil(pr)
    }
    
    func test_maxRepsPR_returnsMaxRepsFromMatchingExerciseThatHasFinished() throws {
        let exerciseId = UUID()
        let prSet = anySet(reps: 10, isFinished: true)
        let prEntry = anyEntry(exercise: exerciseId, sets: [anySet(reps: 1, isFinished: true), prSet])
        let prSession = anySession(entries: [prEntry])
        let workouts = [
            prSession,
            anySession(entries: [
                anyEntry(
                    exercise: exerciseId,
                    sets: [anySet(reps: 5, isFinished: false), anySet(reps: 40, isFinished: false)])])
        ]
        
        let pr = try XCTUnwrap(PRCalculator.maxRepsPR(for: exerciseId, from: workouts))
        
        XCTAssertEqual(pr.session, prSession)
        XCTAssertEqual(pr.entry, prEntry)
        XCTAssertEqual(pr.set, prSet)
    }
}
