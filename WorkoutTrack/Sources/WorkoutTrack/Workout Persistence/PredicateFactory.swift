//
//  PredicateFactory.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/22.
//

import Foundation
import SwiftData

struct PredicateFactory {
    static func getPredicate(_ id: UUID?, _ date: ClosedRange<Date>?) -> Predicate<WorkoutSession> {
        if #available(macOS 14.4, iOS 17.4, *) {
            return newPredicate(id, date)
        } else {
            return legacyPredicate(id, date)
        }
    }
    
    @available(macOS 14.4, iOS 17.4, *)
    private static func newPredicate(_ id: UUID?, _ date: ClosedRange<Date>?) -> Predicate<WorkoutSession> {
        var idPredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        var datePredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        
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
        
        return #Predicate<WorkoutSession> { session in
            idPredicate.evaluate(session) && datePredicate.evaluate(session)
        }
    }
    
    // TODO: - Haven't covered all the possible predicates.
    private static func legacyPredicate(_ id: UUID?, _ date: ClosedRange<Date>?) -> Predicate<WorkoutSession> {
        switch (id, date) {
        case (let id?, nil):
            return #Predicate { $0.id == id }
        case (nil, let date?):
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            return #Predicate { (lowerbound...upperbound).contains($0.date) }
        case (let id?, let date?):
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            return #Predicate { $0.id == id && (lowerbound...upperbound).contains($0.date) }
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
