//
//  OneRepMaxCalculator.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import Foundation

public struct OneRepMaxRecord: Equatable {
    public let date: Date
    public let oneRepMax: Double
    
    public init(date: Date, oneRepMax: Double) {
        self.date = date
        self.oneRepMax = oneRepMax
    }
}

public struct OneRepMaxCalculator {
    private let calendar: Calendar
    
    public init(calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.calendar = calendar
    }
    
    public func getBestOneRepMax(for exercise: UUID, from workouts: [WorkoutSessionDTO]) -> [OneRepMaxRecord] {
        var dailyBest: [DateComponents: OneRepMaxRecord] = [:]
        
        for session in workouts {
            for entry in session.entries where entry.exerciseID == exercise {
                for set in entry.sets where set.isFinished {
                    let oneRepMax = (set.weight * (1 + Double(set.reps) / 30.0)).rounded(toPlaces: 2)
                    let components = calendar.dateComponents([.year, .month, .day], from: session.date)
                    
                    if let current = dailyBest[components] {
                        if oneRepMax > current.oneRepMax {
                            dailyBest[components] = OneRepMaxRecord(date: session.date, oneRepMax: oneRepMax)
                        }
                    } else {
                        dailyBest[components] = OneRepMaxRecord(date: session.date, oneRepMax: oneRepMax)
                    }
                }
            }
        }
        
        return dailyBest.values.sorted(by: { $0.date < $1.date })
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
