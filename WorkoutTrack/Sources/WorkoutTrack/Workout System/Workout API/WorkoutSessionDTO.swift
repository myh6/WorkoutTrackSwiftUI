//
//  WorkoutSessionDTO.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/28.
//

import Foundation

public struct WorkoutSessionDTO: Equatable {
    public let id: UUID
    public let date: Date
    public let entries: [WorkoutEntryDTO]
    
    public init(id: UUID, date: Date, entries: [WorkoutEntryDTO]) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

extension WorkoutSessionDTO {
    func withEntries(_ entries: [WorkoutEntryDTO]) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: self.id, date: self.date, entries: entries)
    }
    
    func normalizedSetOrder() -> WorkoutSessionDTO {
        let entries = entries.map { $0.normalizedSetOrder() }
        return withEntries(entries)
    }
}

