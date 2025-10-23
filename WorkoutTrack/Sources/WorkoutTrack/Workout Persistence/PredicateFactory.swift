//
//  PredicateFactory.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/22.
//

import Foundation
import SwiftData

struct PredicateFactory {
    static func getPredicate(_ id: UUID?, _ date: ClosedRange<Date>?, _ exercise: [UUID]?) -> Predicate<WorkoutSession> {
        if #available(macOS 14.4, iOS 17.4, *) {
            return newPredicate(id, date, exercise)
        } else {
            return legacyPredicate(id, date, exercise)
        }
    }
    
    @available(macOS 14.4, iOS 17.4, *)
    private static func newPredicate(_ id: UUID?, _ date: ClosedRange<Date>?, _ exercise: [UUID]?) -> Predicate<WorkoutSession> {
        var idPredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        var datePredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        var exercisePredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        
        if let id {
            idPredicate = #Predicate { $0.id == id }
        }
        
        if let date {
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            
            datePredicate = #Predicate {
                (lowerbound...upperbound).contains($0.date)
            }
        }
        
        if let exercise {
            exercisePredicate = #Predicate {
                $0.entries.contains(where: { entry in exercise.contains(entry.exerciseID) })
            }
        }
        
        return #Predicate<WorkoutSession> { session in
            idPredicate.evaluate(session) && datePredicate.evaluate(session) && exercisePredicate.evaluate(session)
        }
    }
    
    private static func legacyPredicate(_ id: UUID?, _ date: ClosedRange<Date>?, _ exercises: [UUID]?) -> Predicate<WorkoutSession> {
        switch (id, date, exercises) {
        case (let id?, nil, nil):
            return #Predicate { $0.id == id }
        case let (nil, date?, nil):
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            return #Predicate { (lowerbound...upperbound).contains($0.date) }
        case (let id?, let date?, nil):
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            return #Predicate { $0.id == id && (lowerbound...upperbound).contains($0.date) }
        case (nil, nil, let exercises?):
            return #Predicate {
                $0.entries.contains(where: { entry in exercises.contains(entry.exerciseID) })
            }
        default:
            return #Predicate { _ in true }
        }
    }
}

extension Date {
    func startOfDay(using calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    func endOfDay(using calendar: Calendar = .current) -> Date {
        let start = startOfDay(using: calendar)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
    }
}
