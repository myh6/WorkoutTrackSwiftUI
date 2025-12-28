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
    var transform: ([WorkoutSession]) -> [WorkoutSession] {
        switch self {
        case .sortByEntryCustomOrder:
            return Self.sortByEntryCustomOrder
        case .containsExercises(let ids):
            return { session in
                Self.containsExercises(ids: ids, in: session)
            }
        case .onlyIncludFinishedSets:
            return Self.onlyIncludeFinishedSets
        case .onlyIncludeExercises(let ids):
            return { session in
                Self.onlyIncludeExercises(ids: ids, in: session)
            }
        }
    }
    
    private static func sortByEntryCustomOrder(sessions: [WorkoutSession]) -> [WorkoutSession] {
        sessions.map { session in
            WorkoutSession(
                id: session.id,
                date: session.date,
                entries: session.entries.sorted { $0.order < $1.order }
            )
        }
    }
    
    private static func containsExercises(ids: [UUID], in sessions: [WorkoutSession]) -> [WorkoutSession] {
        let set = Set(ids)
        return sessions.filter { session in
            let exerciseIds = Set(session.entries.map(\.exerciseID))
            return !exerciseIds.isDisjoint(with: set)
        }
    }
    
    private static func onlyIncludeFinishedSets(sessions: [WorkoutSession]) -> [WorkoutSession] {
        sessions.map { session in
            WorkoutSession(
                id: session.id,
                date: session.date,
                entries: session.entries.map { entry in
                    WorkoutEntry(
                        id: entry.id,
                        exerciseID: entry.exerciseID,
                        sets: entry.sets.filter { $0.isFinished },
                        createdAt: entry.createdAt,
                        order: entry.order)
                })
        }
    }
    
    private static func onlyIncludeExercises(ids: [UUID], in sessions: [WorkoutSession])
    -> [WorkoutSession] {
        sessions.map { session in
            WorkoutSession(
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
