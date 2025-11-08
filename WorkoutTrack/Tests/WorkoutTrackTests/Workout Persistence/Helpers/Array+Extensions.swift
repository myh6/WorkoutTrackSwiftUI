//
//  Array+Extensions.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//
import Foundation
@testable import WorkoutTrack

extension Array where Element == WorkoutSessionDTO {
    func sortedBySessionInAscendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.id < $1.id }
    }
    
    func sortedBySessionInDescendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.id > $1.id }
    }
    
    func sortedByDateInAscendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.date < $1.date }
    }
    
    func sortedByDateInDescendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.date > $1.date }
    }
}

extension Array where Element == WorkoutEntryDTO {
    func sortedByDefaultOrder() -> [WorkoutEntryDTO] {
        return sortedByEntryCreatedAtInAscendingOrder()
    }
    
    func sortedByEntryCreatedAtInAscendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.createdAt < $1.createdAt }
    }
}

extension Array where Element == WorkoutSetDTO {
    func sortedByDefaultOrder() -> [WorkoutSetDTO] {
        sortedByOrder()
    }
    
    func sortedByOrder() -> [WorkoutSetDTO] {
        sorted { $0.order < $1.order }
    }
}

