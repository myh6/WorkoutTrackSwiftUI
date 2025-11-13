//
//  VolumeCalculator.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import Foundation

public struct VolumeStat: Equatable {
    public let date: Date
    public let volume: Double
    
    public init(date: Date, volume: Double) {
        self.date = date
        self.volume = volume
    }
}

public struct VolumeCalculator {
    public static func getDailyVolume(from workouts: [WorkoutSessionDTO], filteredByExercise exercise: UUID?) -> [VolumeStat] {
        return workouts.map { session in
            let totalVolume = session.entries
                .filter {
                    if let exercise { return $0.exerciseID == exercise }
                    return true
                }
                .flatMap(\.sets)
                .filter(\.isFinished)
                .reduce(0.0, VolumeCalculator.calculateVolume)
            return VolumeStat(date: session.date, volume: totalVolume)
        }
    }
    
    public static func volumePerExercise(from sessions: [WorkoutSessionDTO]) -> [UUID: Double] {
        var res = [UUID: Double]()
        
        for session in sessions {
            for entry in session.entries {
                let volume = entry.sets
                    .filter(\.isFinished)
                    .reduce(0.0, VolumeCalculator.calculateVolume)
                res[entry.exerciseID, default: 0.0] += volume
            }
        }
        return res
    }
    
    private static func calculateVolume(_ initial: Double, _ nextSet: WorkoutSetDTO) -> Double {
        initial + (Double(nextSet.reps) * nextSet.weight)
    }
}
