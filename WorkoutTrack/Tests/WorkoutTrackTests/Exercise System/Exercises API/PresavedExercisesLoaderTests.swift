//
//  ExercisesLoaderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/22.
//

import XCTest
@testable import WorkoutTrack

final class PresavedExercisesLoaderTests: XCTestCase {
    
    func test_loader_returnsAllPresavedExercises() async throws {
        let all = try await makeSUT().loadExercises(by: .all(sort: .none))
        
        XCTAssertEqual(all.count, 110)
        all.forEach {
            XCTAssertFalse($0.isCustom)
        }
    }
    
    func test_load_allWithoutSorting_returnsAllExercisesSortedByNameInDefault() async throws {
        let retrieved = try await makeSUT().loadExercises(by: .all(sort: .none))
        let baseline = retrieved.sortedInNameAscendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithNameAscending_returnsAllExercisesSortedByNameInAscendingOrder() async throws {
        let retrieved = try await makeSUT().loadExercises(by: .all(sort: .name(ascending: true)))
        let baseline = retrieved.sortedInNameAscendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithNameDescending_returnsAllExercisesSortedByNameInDescendingOrder() async throws {
        let retrieved = try await makeSUT().loadExercises(by: .all(sort: .name(ascending: false)))
        let baseline = retrieved.sortedInNameDescendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithCategoryAscending_returnsAllExercisesSortedByCategoryInAscendingOrder() async throws {
        let retrieved = try await makeSUT().loadExercises(by: .all(sort: .category(ascending: true)))
        let baseline = retrieved.sortedInCategoryAscendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_allWithCategoryAscending_returnsAllExercisesSortedByCategoryInDescendingOrder() async throws {
        let retrieved = try await makeSUT().loadExercises(by: .all(sort: .category(ascending: false)))
        let baseline = retrieved.sortedInCategoryDescendingOrder()
        
        assertSameIDs(inOrder: baseline, retrieved)
    }
    
    func test_load_byID_returnsTheOnlyOneWithThatID() async throws {
        let testId = getPushUpID()
        let retrieved = try await makeSUT().loadExercises(by: .byID(testId))
        
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved[0].id, testId)
    }
    
    func test_load_byName_returnsAllValidExercisesIgnoringCasesWithSimilarNameInAscedingOrder() async throws {
        let testName = "squat"
        let retrieved = try await makeSUT().loadExercises(by: .byName(testName, sort: .name(ascending: true)))
        
        XCTAssertEqual(retrieved.count, 4)
        retrieved.forEach {
            XCTAssertTrue($0.name.localizedCaseInsensitiveContains(testName))
        }
        XCTAssertTrue(retrieved.isInAscendingOrder())
    }
    
    func test_load_byName_returnsAllValidExercisesIgnoringCasesWithSimilarNameInDescendingOrder() async throws {
        let testName = "squat"
        let retrieved = try await makeSUT().loadExercises(by: .byName(testName, sort: .name(ascending: false)))
        
        XCTAssertEqual(retrieved.count, 4)
        retrieved.forEach {
            XCTAssertTrue($0.name.localizedCaseInsensitiveContains(testName))
        }
        XCTAssertTrue(retrieved.isInDescendingOrder())
    }
    
    func test_load_byCategory_returnsAllExercisesFromTheSpecificedCategroyWithNameInAscendingOrderIgnoringCases() async throws {
        let testCategory: BodyCategory = .chest
        let retrieved = try await makeSUT().loadExercises(by: .byCategory(testCategory, sort: .name(ascending: true)))

        XCTAssertEqual(retrieved.count, 16)
        retrieved.forEach {
            XCTAssertEqual($0.category, testCategory.localizedName)
        }
        XCTAssertTrue(retrieved.isInAscendingOrder())
    }
    
    func test_load_byCategory_returnsAllExercisesFromTheSpecificedCategroyWithNameInDescendingOrderIgnoringCases() async throws {
        let testCategory: BodyCategory = .chest
        let retrieved = try await makeSUT().loadExercises(by: .byCategory(testCategory, sort: .name(ascending: false)))
        
        XCTAssertEqual(retrieved.count, 16)
        retrieved.forEach {
            XCTAssertEqual($0.category, testCategory.localizedName)
        }
        XCTAssertTrue(retrieved.isInDescendingOrder())
    }
    
    //MARK: - Helpers
    private func makeSUT() -> ExerciseLoader {
        // No need to check for memory leaks since we used it as a statless struct.
        return PresavedExercisesLoader()
    }
    
    private func assertSameIDs(inOrder expected: [DisplayableExercise], _ actual: [DisplayableExercise], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.map(\.id), actual.map(\.id), file: file, line: line)
    }

}
