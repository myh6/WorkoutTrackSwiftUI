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
    
    static func sections(from sessions: [WorkoutSession],
                         expandedExerciseIDs: Set<UUID>,
                         nameForExerciseID: ExerciseNameResolver) -> [ExerciseSection] {
        return []
    }
}

struct WorkoutDayMapperTests {
    
    @Test
    func sections_emptySessions_returnEmpty() {
        let result = WorkoutDayMapper.sections(from: [], expandedExerciseIDs: [], nameForExerciseID: { _ in nil })
        
        #expect(result.isEmpty)
    }
    
}
