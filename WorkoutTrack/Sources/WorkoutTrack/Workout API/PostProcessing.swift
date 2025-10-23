//
//  PostProcessing.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/23.
//

import Foundation

public enum PostProcessing: Equatable {
    case sortByEntryCustomOrder
    case onlyIncludFinishedSets
    case onlyIncludeExercises([UUID])
    case limitToFirst(Int)
}

extension PostProcessing {
    var transform: ([WorkoutSessionDTO]) -> [WorkoutSessionDTO] {
        switch self {
        case .sortByEntryCustomOrder:
            return { sessions in
                sessions.map { session in
                    WorkoutSessionDTO(
                        id: session.id,
                        date: session.date,
                        entries: session.entries.sorted { $0.order < $1.order }
                    )
                }
            }
            
        case .onlyIncludFinishedSets:
            return { sessions in
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
        default:
            return { _ in [] }
        }
    }
}
