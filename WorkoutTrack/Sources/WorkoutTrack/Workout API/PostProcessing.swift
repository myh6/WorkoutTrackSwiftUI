//
//  PostProcessing.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/23.
//

import Foundation

public enum PostProcessing: Equatable {
    case sortByEntryCustomOrder
    case containsExercises([UUID])
    case onlyIncludFinishedSets
    case onlyIncludeExercises([UUID])
}

extension PostProcessing {
    var transform: ([WorkoutSessionDTO]) -> [WorkoutSessionDTO] {
        switch self {
        case .sortByEntryCustomOrder:
            return Self.sortByEntryCustomOrder
        case .containsExercises(let ids):
            return { _ in [] }
        case .onlyIncludFinishedSets:
            return Self.onlyIncludeFinishedSets
        case .onlyIncludeExercises(let ids):
            return { session in
                Self.onlyIncludeExercises(ids: ids, in: session)
            }
        }
    }
    
    private static func sortByEntryCustomOrder(sessions: [WorkoutSessionDTO]) -> [WorkoutSessionDTO] {
        sessions.map { session in
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: session.entries.sorted { $0.order < $1.order }
            )
        }
    }
    
    private static func onlyIncludeFinishedSets(sessions: [WorkoutSessionDTO]) -> [WorkoutSessionDTO] {
        sessions.map { session in
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: session.entries.map { entry in
                    WorkoutEntryDTO(
                        id: entry.id,
                        exerciseID: entry.exerciseID,
                        sets: entry.sets.filter { $0.isFinished },
                        createdAt: entry.createdAt,
                        order: entry.order)
                })
        }
    }
    
    private static func onlyIncludeExercises(ids: [UUID], in sessions: [WorkoutSessionDTO])
    -> [WorkoutSessionDTO] {
        sessions.map { session in
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: session.entries.filter {
                    ids.contains($0.exerciseID)
                }
            )
        }
        .filter { !$0.entries.isEmpty }
    }
}
