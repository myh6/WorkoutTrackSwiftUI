//
//  VolumeCalculatorTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/10.
//

import XCTest
import WorkoutTrack

struct VolumeStat: Equatable {
    let date: Date
    let volume: Double
}

struct VolumeCalculator {
    static func getDailyVolume(from workouts: [WorkoutSessionDTO], filteredByExercise exercise: UUID?) -> [VolumeStat] {
        return workouts.map { session in
            let totalVolume = session.entries
                .flatMap(\.sets)
                .filter(\.isFinished)
                .reduce(0.0) {
                    $0 + (Double($1.reps) * $1.weight)
                }
            return VolumeStat(date: session.date, volume: totalVolume)
        }
    }
}

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
}

private extension Array where Element == VolumeStat {
    func sortedByDate() -> [VolumeStat] {
        return sorted(by: {
            $0.date < $1.date
        })
    }
}
