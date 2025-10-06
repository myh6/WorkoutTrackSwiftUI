//
//  ExercisesLoaderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/22.
//

import XCTest
@testable import WorkoutTrack

final class PresavedExercisesLoaderTests: XCTestCase {
    
    func test_loader_returnsAllExercises() {
        let loader = PresavedExercisesLoader()
        let all = loader.loadExercises(by: .all(sort: .none))
        XCTAssertEqual(all.count, 110)
    }
    
    func test_load_allWithoutSorting_returnsAllExercisesSortedByNameInDefault() {
        let loader = PresavedExercisesLoader()
        let retrieved = loader.loadExercises(by: .all(sort: .none))
        let baseline = retrieved.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithNameAscending_returnsAllExercisesSortedByNameInAscendingOrder() {
        let loader = PresavedExercisesLoader()
        let retrieved = loader.loadExercises(by: .all(sort: .name(ascending: true)))
        let baseline = retrieved.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    //MARK: - Helpers
    private func assertSameIDs(inOrder expected: [DisplayableExercise], _ actual: [DisplayableExercise], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.map(\.id), actual.map(\.id), file: file, line: line)
    }

}
