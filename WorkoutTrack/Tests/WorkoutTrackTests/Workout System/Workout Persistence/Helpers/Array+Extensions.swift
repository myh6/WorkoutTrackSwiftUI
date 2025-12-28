//
//  Array+Extensions.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//
import Foundation
@testable import WorkoutTrack

extension Array where Element == WorkoutSession {
    func sortedBySessionInAscendingOrder() -> [WorkoutSession] {
        sorted { $0.id < $1.id }
    }
    
    func sortedBySessionInDescendingOrder() -> [WorkoutSession] {
        sorted { $0.id > $1.id }
    }
    
    func sortedByDateInAscendingOrder() -> [WorkoutSession] {
        sorted { $0.date < $1.date }
    }
    
    func sortedByDateInDescendingOrder() -> [WorkoutSession] {
        sorted { $0.date > $1.date }
    }
}

extension Array where Element == WorkoutEntry {
    func sortedByDefaultOrder() -> [WorkoutEntry] {
        return sortedByEntryCreatedAtInAscendingOrder()
    }
    
    func sortedByEntryCreatedAtInAscendingOrder() -> [WorkoutEntry] {
        sorted { $0.createdAt < $1.createdAt }
    }
}

extension Array where Element == WorkoutSet {
    func sortedByDefaultOrder() -> [WorkoutSet] {
        sortedByOrder()
    }
    
    func sortedByOrder() -> [WorkoutSet] {
        sorted { $0.order < $1.order }
    }
}

