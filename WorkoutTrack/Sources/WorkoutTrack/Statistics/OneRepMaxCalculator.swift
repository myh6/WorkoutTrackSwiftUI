//
//  OneRepMaxCalculator.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import Foundation

public struct OneRepMaxRecord {
    public let date: Date
    public let oneRepMax: Double
}

public struct OneRepMaxCalculator {
    public static func getBestOneRepMax(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> OneRepMaxRecord? {
        var best: (date: Date, oneRpmMax: Double)? = nil
        
        for session in workouts {
            for entry in session.entries where entry.exerciseID == exercise {
                for set in entry.sets where set.isFinished {
                    let oneRepMax = set.weight * (1 + Double(set.reps) / 30.0)
                    if let currBest = best?.oneRpmMax, oneRepMax > currBest {
                        best = (session.date, oneRepMax)
                    } else {
                        best = (session.date, oneRepMax)
                    }
                }
            }
        }
        
        if let best = best {
            return OneRepMaxRecord(date: best.date, oneRepMax: best.oneRpmMax)
        } else {
            return nil
        }
    }
}
