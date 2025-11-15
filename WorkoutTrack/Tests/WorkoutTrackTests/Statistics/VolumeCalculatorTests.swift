//
//  VolumeCalculatorTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/10.
//

import XCTest
import WorkoutTrack

final class VolumeCalculatorTests: XCTestCase {
    
    func test_getDailyVolume_returnsEmptyWhenNoWorkout() {
        let result = VolumeCalculator.getDailyVolume(from: [], filteredByExercise: nil)
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getDailyVolume_filteredExercise_returnsEmptyWhenNoWorkout() {
        let result = VolumeCalculator.getDailyVolume(from: [], filteredByExercise: UUID())
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getDailyVolume_withNoFilteredExercise_returnsAllWorkoutVolumeFromProvidedWorkout() {
        let workouts = [
            getTodaySession(),
            getOneDaysBeforeSession(),
            getTwoDaysBeforeSession()
        ]
        
        let result = VolumeCalculator.getDailyVolume(from: workouts.map(\.session), filteredByExercise: nil)
        
        XCTAssertEqual(result.sortedByDate(),
                       workouts.map(\.volume).sortedByDate())
    }
    
    func test_getDailyVolume_filteredExercise_returnsOnlyVolumeOfTheFilteredExercise() {
        let exerciseId = UUID()
        let workouts = [
            getTodaySessionWithMixedExercises(targetExercise: exerciseId),
            getOneDayBeforeSessionWithMixedExercises(targetExercise: exerciseId),
            getTwoDaysBeforeSessionWithMixedExercises(targetExercise: exerciseId)
        ]
        
        let result = VolumeCalculator.getDailyVolume(from: workouts.map(\.session), filteredByExercise: exerciseId)
        
        XCTAssertEqual(result.sortedByDate(),
                       workouts.map(\.volume).sortedByDate())
    }
    
    func test_volumePerExercise_returnsEmptyWhenNoWorkout() {
        let result = VolumeCalculator.volumePerExercise(from: [])
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_volumePerExercise_returnsCorrectAggregatedVolumePerExercise() {
        let exerciseA = UUID()
        let exerciseB = UUID()
        
        let sessions: [WorkoutSessionDTO] = [
            anySession(entries: [
                anyEntry(exercise: exerciseA, sets: [
                    anySet(reps: 10, weight: 20, isFinished: true),  // 200
                    anySet(reps: 5, weight: 20, isFinished: false)   // ignored
                ]),
                anyEntry(exercise: exerciseB, sets: [
                    anySet(reps: 5, weight: 10, isFinished: true)    // 50
                ])
            ]),
            anySession(entries: [
                anyEntry(exercise: exerciseA, sets: [
                    anySet(reps: 5, weight: 10, isFinished: true)    // 50
                ])
            ])
        ]
        
        let result = VolumeCalculator.volumePerExercise(from: sessions)
        XCTAssertEqual(result[exerciseA], 250)
        XCTAssertEqual(result[exerciseB], 50)
    }
    
    //MARK: - Helpers
    private func getTwoDaysBeforeSession() -> (session: WorkoutSessionDTO, volume: VolumeStat) {
        let date = Date().adding(days: -2)
        let session = anySession(date: date, entries: [
            anyEntry(sets: [
                anySet(reps: 10, weight: 20, isFinished: true),
                anySet(reps: 10, weight: 20, isFinished: true),
                anySet(reps: 10, weight: 20, isFinished: false)
            ]),
            anyEntry(sets: [
                anySet(reps: 5, weight: 10, isFinished: true),
                anySet(reps: 5, weight: 15, isFinished: true),
                anySet(reps: 5, weight: 20, isFinished: false)
            ])
        ])
        
        return (session, VolumeStat(date: date, volume: 525))
    }
    
    private func getOneDaysBeforeSession() -> (session: WorkoutSessionDTO, volume: VolumeStat) {
        let date = Date().adding(days: -1)
        let session = anySession(date: date, entries: [
            anyEntry(sets: [
                anySet(reps: 20, weight: 10, isFinished: true),
                anySet(reps: 10, weight: 20, isFinished: false)
            ]),
            anyEntry(sets: [
                anySet(reps: 5, weight: 5, isFinished: true),
                anySet(reps: 5, weight: 20, isFinished: false)
            ])
        ])
        
        return (session, VolumeStat(date: date, volume: 225))
    }
    
    private func getTodaySession() -> (session: WorkoutSessionDTO, volume: VolumeStat) {
        let date = Date()
        let session = anySession(date: date, entries: [
            anyEntry(sets: [
                anySet(reps: 5, weight: 20, isFinished: true),
                anySet(reps: 10, weight: 20, isFinished: false)
            ]),
            anyEntry(sets: [
                anySet(reps: 5, weight: 35, isFinished: true),
                anySet(reps: 5, weight: 20, isFinished: false)
            ])
        ])
        
        return (session, VolumeStat(date: date, volume: 275))
    }
    
    // MARK: - Filtered Exercise Helpers
    private func getTodaySessionWithMixedExercises(targetExercise: UUID) -> (session: WorkoutSessionDTO, volume: VolumeStat) {
        let date = Date()
        let unrelatedExercise = UUID()

        let session = anySession(date: date, entries: [
            anyEntry(exercise: targetExercise, sets: [
                anySet(reps: 5, weight: 20, isFinished: true),
                anySet(reps: 10, weight: 20, isFinished: false)
            ]),
            anyEntry(exercise: unrelatedExercise, sets: [
                anySet(reps: 5, weight: 35, isFinished: true),
                anySet(reps: 5, weight: 20, isFinished: false)
            ])
        ])

        // Only the first entry (target exercise) contributes: 5 × 20 = 100
        return (session, VolumeStat(date: date, volume: 100))
    }

    private func getOneDayBeforeSessionWithMixedExercises(targetExercise: UUID) -> (session: WorkoutSessionDTO, volume: VolumeStat) {
        let date = Date().adding(days: -1)
        let unrelatedExercise = UUID()

        let session = anySession(date: date, entries: [
            anyEntry(exercise: unrelatedExercise, sets: [
                anySet(reps: 10, weight: 10, isFinished: true),
                anySet(reps: 5, weight: 20, isFinished: true)
            ]),
            anyEntry(exercise: targetExercise, sets: [
                anySet(reps: 5, weight: 5, isFinished: true),
                anySet(reps: 5, weight: 10, isFinished: false)
            ])
        ])

        // Only the target entry contributes: 5 × 5 = 25
        return (session, VolumeStat(date: date, volume: 25))
    }

    private func getTwoDaysBeforeSessionWithMixedExercises(targetExercise: UUID) -> (session: WorkoutSessionDTO, volume: VolumeStat) {
        let date = Date().adding(days: -2)
        let unrelatedExercise = UUID()

        let session = anySession(date: date, entries: [
            anyEntry(exercise: unrelatedExercise, sets: [
                anySet(reps: 8, weight: 15, isFinished: true),
                anySet(reps: 8, weight: 15, isFinished: true)
            ]),
            anyEntry(exercise: targetExercise, sets: [
                anySet(reps: 5, weight: 20, isFinished: true),
                anySet(reps: 5, weight: 20, isFinished: true)
            ])
        ])

        // Only target entry contributes: (5×20) + (5×20) = 200
        return (session, VolumeStat(date: date, volume: 200))
    }
}

private extension Array where Element == VolumeStat {
    func sortedByDate() -> [VolumeStat] {
        return sorted(by: {
            $0.date < $1.date
        })
    }
}
