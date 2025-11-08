//
//  ExercisesLoaderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/22.
//

import XCTest
@testable import WorkoutTrack

final class PresavedExercisesLoaderTests: XCTestCase {
    
    func test_loader_returnsAllPresavedExercises() {
        let all = PresavedExercisesLoader().loadExercises(by: .all(sort: .none))
        
        XCTAssertEqual(all.count, 110)
        all.forEach {
            XCTAssertFalse($0.isCustom)
        }
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
    
    func test_load_allWithCategoryAscending_returnsAllExercisesSortedByCategoryInAscendingOrder() {
        let retrieved = PresavedExercisesLoader().loadExercises(by: .all(sort: .category(ascending: true)))
        let baseline = retrieved.sortedInCategoryAscendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithCategoryAscending_returnsAllExercisesSortedByCategoryInDescendingOrder() {
        let retrieved = PresavedExercisesLoader().loadExercises(by: .all(sort: .category(ascending: false)))
        let baseline = retrieved.sortedInCategoryDescendingOrder()
        
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
    
    func test_load_byCategory_returnsAllExercisesFromTheSpecificedCategroyWithNameInAscendingOrderIgnoringCases() {
        let testCategory = "chest"
        let retrieved = PresavedExercisesLoader().loadExercises(by: .byCategory(testCategory.uppercased(), sort: .name(ascending: true)))

        XCTAssertEqual(retrieved.count, 16)
        retrieved.forEach {
            XCTAssertEqual($0.category.lowercased(), testCategory.lowercased())
        }
        XCTAssertTrue(retrieved.isInAscendingOrder())
    }
    
    func test_load_byCategory_returnsAllExercisesFromTheSpecificedCategroyWithNameInDescendingOrderIgnoringCases() {
        let testCategory = "chest"
        let retrieved = PresavedExercisesLoader().loadExercises(by: .byCategory(testCategory.uppercased(), sort: .name(ascending: false)))
        
        XCTAssertEqual(retrieved.count, 16)
        retrieved.forEach {
            XCTAssertEqual($0.category.lowercased(), testCategory.lowercased())
        }
        XCTAssertTrue(retrieved.isInDescendingOrder())
    }
    
    //MARK: - Helpers
    private func assertSameIDs(inOrder expected: [DisplayableExercise], _ actual: [DisplayableExercise], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.map(\.id), actual.map(\.id), file: file, line: line)
    }

}
