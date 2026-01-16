//
//  WorkoutDayMapper.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/16.
//

import Foundation
import WorkoutTrack

struct WorkoutDayMapper {
    typealias ExerciseNameResolver = (UUID) -> String?
    
    static func sections(from sessions: WorkoutSession?,
                         expandedEntryIDs: Set<UUID>,
                         nameForExerciseID: ExerciseNameResolver) -> [ExerciseSection] {
        guard let sessions else { return [] }
        
        return sessions.entries.map {
            ExerciseSection(
                id: $0.id,
                title: nameForExerciseID($0.exerciseID) ?? "Unknown Exercise",
                sets: $0.sets.map(sets).sorted { $0.order < $1.order },
                isExpanded: expandedEntryIDs.contains($0.id))
        }
    }
    
    private static func sets(from set: WorkoutSet) -> SetRow {
        SetRow(id: set.id, reps: set.reps, weight: set.weight, isFinished: set.isFinished, order: set.order)
    }
}
