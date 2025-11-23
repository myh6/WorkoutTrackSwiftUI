//
//  StreakAnalyzer.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import Foundation

public struct StreakAnalyzer {
    public static func getWorkoutDays(from workouts: [WorkoutSessionDTO], calendar: Calendar = .current) -> [Date: Bool] {
        var result: [Date: Bool] = [:]
        
        for session in workouts {
            let day = session.date.startOfDay(using: calendar)
            result[day] = true
        }
        
        return result
    }
}
