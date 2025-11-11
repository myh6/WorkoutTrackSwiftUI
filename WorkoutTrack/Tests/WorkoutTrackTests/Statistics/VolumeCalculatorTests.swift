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
    static func getDailyVolume(from workouts: [WorkoutSessionDTO]) -> [VolumeStat] {
        return []
    }
}

final class VolumeCalculatorTests: XCTestCase {
    
    func tes_getDailyVolume_returnsEmptyWhenNoWorkout() {
        let result = VolumeCalculator.getDailyVolume(from: [])
        
        XCTAssertEqual(result, [])
    }
}
