//
//  WorkoutSessionDTO.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/28.
//

import Foundation

// DTO
public struct WorkoutSession: Equatable {
    public let id: UUID
    public let date: Date
    public let entries: [WorkoutEntry]
    
    public init(id: UUID, date: Date, entries: [WorkoutEntry]) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

extension WorkoutSession {
    func withEntries(_ entries: [WorkoutEntry]) -> WorkoutSession {
        WorkoutSession(id: self.id, date: self.date, entries: entries)
    }
    
    func normalizedSetOrder() -> WorkoutSession {
        let entries = entries.map { $0.normalizedSetOrder() }
        return withEntries(entries)
    }
}

