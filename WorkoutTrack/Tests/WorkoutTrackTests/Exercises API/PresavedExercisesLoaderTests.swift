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
        let all = PresavedExercisesLoader().loadExercises(by: .all(sort: .none))
        XCTAssertEqual(all.count, 110)
    }
    
    func test_load_allWithoutSorting_returnsAllExercisesSortedByNameInDefault() {
        let retrieved = PresavedExercisesLoader().loadExercises(by: .all(sort: .none))
        let baseline = retrieved.sortedInNameAscendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithNameAscending_returnsAllExercisesSortedByNameInAscendingOrder() {
        let retrieved = PresavedExercisesLoader().loadExercises(by: .all(sort: .name(ascending: true)))
        let baseline = retrieved.sortedInNameAscendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithNameDescending_returnsAllExercisesSortedByNameInDescendingOrder() {
        let retrieved = PresavedExercisesLoader().loadExercises(by: .all(sort: .name(ascending: false)))
        let baseline = retrieved.sortedInNameDescendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_byID_returnsTheOnlyOneWithThatID() {
        let testId = UUID(uuidString: "762D25FA-5659-4C2C-627D-9788B9F89EAF")!
        let retrieved = PresavedExercisesLoader().loadExercises(by: .byID(testId))
        
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].id, testId)
    }
    
    func test_load_byName_returnsAllValidExercisesIgnoringCasesWithSimilarNameInAscedingOrder() {
        let testName = "squat"
        let retrieved = PresavedExercisesLoader().loadExercises(by: .byName(testName, sort: .name(ascending: true)))
        
        XCTAssertEqual(retrieved.count, 4)
        retrieved.forEach {
            XCTAssertTrue($0.name.localizedCaseInsensitiveContains(testName))
        }
        XCTAssertTrue(retrieved.isInAscendingOrder())
    }
    
    func test_load_byName_returnsAllValidExercisesIgnoringCasesWithSimilarNameInDescendingOrder() {
        let testName = "squat"
        let retrieved = PresavedExercisesLoader().loadExercises(by: .byName(testName, sort: .name(ascending: false)))
        
        XCTAssertEqual(retrieved.count, 4)
        retrieved.forEach {
            XCTAssertTrue($0.name.localizedCaseInsensitiveContains(testName))
        }
        XCTAssertTrue(retrieved.isInDescendingOrder())
    }
    
    //MARK: - Helpers
    private func assertSameIDs(inOrder expected: [DisplayableExercise], _ actual: [DisplayableExercise], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.map(\.id), actual.map(\.id), file: file, line: line)
    }

}

extension Array where Element == DisplayableExercise {
    func sortedInNameAscendingOrder() -> [DisplayableExercise] {
        sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    func sortedInNameDescendingOrder() -> [DisplayableExercise] {
        sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
    }
    
    func isInAscendingOrder() -> Bool {
        let res = self.sortedInNameAscendingOrder().map(\.id)
        let retrievedID = self.map(\.id)
        return res == retrievedID
    }
    
    func isInDescendingOrder() -> Bool {
        let res = self.sortedInNameDescendingOrder().map(\.id)
        let retrievedID = self.map(\.id)
        return res == retrievedID
    }
}
