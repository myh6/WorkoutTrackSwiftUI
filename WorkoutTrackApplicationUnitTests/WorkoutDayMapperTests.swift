//
//  WorkoutDayMapperTests.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/4.
//

import Testing
import Foundation
import WorkoutTrack
@testable import WorkoutTrackSwiftUI

struct WorkoutDayMapper {
    typealias ExerciseNameResolver = (UUID) -> String?
    
    static func sections(from sessions: WorkoutSession?,
                         expandedExerciseIDs: Set<UUID>,
                         nameForExerciseID: ExerciseNameResolver) -> [ExerciseSection] {
        guard let sessions else { return [] }
        
        return sessions.entries.map {
            ExerciseSection(
                id: $0.id,
                title: nameForExerciseID($0.exerciseID) ?? "Unkown Exercise",
                sets: $0.sets.map(sets),
                isExpanded: expandedExerciseIDs.contains($0.id))
        }
    }
    
    private static func sets(from set: WorkoutSet) -> SetRow {
        SetRow(id: set.id, reps: set.reps, weight: set.weight, isFinished: set.isFinished, order: set.order)
    }
}

struct WorkoutDayMapperTests {
    
    @Test
    func sections_emptySession_returnEmpty() {
        let result = WorkoutDayMapper.sections(from: .none, expandedExerciseIDs: [], nameForExerciseID: { _ in nil })
        
        #expect(result.isEmpty)
    }
    
    @Test
    func sections_singleEntry_mapsToSingleSectionWithSetRows() {
        let exercise = UUID()
        let set1 = anySet(weight: 10.0, isFinished: false, order: 0)
        let set2 = anySet(weight: 20.0, isFinished: true, order: 1)
        
        let entry = anyEntry(exercise: exercise, sets: [set1, set2])
        let session = anySession(entries: [entry])
        
        let result = WorkoutDayMapper.sections(from: session, expandedExerciseIDs: [], nameForExerciseID: { _ in "Test Exercise" })
        
        #expect(result.count == 1)
        
        let section = result[0]
        #expect(section.isExpanded == false)
        #expect(section.id == entry.id)
        #expect(section.title == "Test Exercise")
        #expect(section.sets.count == 2)
        #expect(section.sets[0].weight == 10.0)
        #expect(section.sets[0].isFinished == false)
        #expect(section.sets[1].weight == 20.0)
        #expect(section.sets[1].isFinished)
    }
    
    @Test
    func sections_fallsBackToUnkownTitle_whenNameProviderReturnsNil() {
        let session = anySession(entries: [anyEntry(exercise: UUID())])
        
        let result = WorkoutDayMapper.sections(from: session, expandedExerciseIDs: []) { _ in nil }
        
        #expect(result.count == 1)
        let section = result[0]
        #expect(section.title == "Unkown Exercise")
    }
    
    //MARK: - Helpers
    private func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSet] = [], created: Date = Date(), order: Int = 0) -> WorkoutEntry {
        return .init(id: id, exerciseID: exercise, sets: sets, createdAt: created, order: order)
    }
    
    private func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0, isFinished: Bool = false, order: Int = 0) -> WorkoutSet {
        return .init(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
    }
}
