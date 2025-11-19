//
//  SwiftDataExerciseStoreTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/9/29.
//

import XCTest
@testable import WorkoutTrack
import SwiftData

final class SwiftDataExerciseStoreTests: XCTestCase {
    
    func test_retrieve_all_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrievedWith: [], with: .all(sort: .none))
    }
    
    func test_retrieve_all_hasNoSideEffectsOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrievedTwiceWith: [], with: .all(sort: .none))
    }
    
    func test_retrieve_all_deliversFoundExercisesOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let anyExercise = anyExercise()
        
        try await sut.insert(anyExercise)
        
        try await expect(sut, toRetrievedWith: [anyExercise], with: .all(sort: .none))
    }
    
    func test_retrieve_all_deliversAllCustomExercisesOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.insert(anyExercise())
        
        let retrieved = try await sut.loadExercises(by: .all(sort: .none))
        
        retrieved.forEach { XCTAssertTrue($0.isCustom) }
    }
    
    func test_retrieve_all_noSorting_deliversAllExercisesSortedByNameInDefault() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()

        try await batchInsert(exercisesInRandom, to: sut)

        let exercisesInOrder = exercisesInRandom.sortedByNameInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .none))
    }
    
    func test_retrieve_all_noSorting_hasNoSideEffects() async throws {
        let sut = makeSUT()
        let exercises = makeExercises(count: 5)
        
        try await batchInsert(exercises, to: sut)
        
        try await expect(sut, toRetrievedTwiceWith: exercises, with: .all(sort: .none))
    }
    
    func test_retrieve_all_sortedByName_deliversAllExercisesSortedByName() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()

        try await batchInsert(exercisesInRandom, to: sut)

        let exercisesInOrder = exercisesInRandom.sortedByNameInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .name(ascending: true)))
    }
    
    func test_retrieve_all_sortedByName_deliversAllExercisesSortedByNameDescending() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()
        
        try await batchInsert(exercisesInRandom, to: sut)
        
        let exercisesInOrder = exercisesInRandom.sortedByNameInDescendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .name(ascending: false)))
    }
    
    func test_retrieve_all_sortedByCategory_deliversAllExercisesSortedByCategory() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeMixedCategoryExercises().shuffled()
        
        try await batchInsert(exercisesInRandom, to: sut)
        
        let exercisesInOrder = exercisesInRandom.sortedByCategoryInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .category(ascending: true)))
    }
    
    func test_retrieve_all_sortedByCategory_deliversAllExercisesSortedByCategoryDescending() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeMixedCategoryExercises().shuffled()
        
        try await batchInsert(exercisesInRandom, to: sut)
        
        let exercisesInOrder = exercisesInRandom.sortedByCategoryInDescendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .category(ascending: false)))
    }
    
    func test_retrieve_byId_deliversTheCorrectExercise() async throws {
        let sut = makeSUT()
        let id = UUID()
        let correctIdExercise = anyExercise(id: id)
        let allExercises = (makeExercises(count: 5) + [correctIdExercise]).shuffled()
        
        try await batchInsert(allExercises, to: sut)
        
        try await expect(sut, toRetrievedWith: [correctIdExercise], with: .byID(id))
    }
    
    func test_retrieve_byName_deliversTheCorrectExercise() async throws {
        let sut = makeSUT()
        let name = "any name"
        let correctNameExercise = anyExercise(name: name)
        let allExercises = (makeExercises(count: 5) + [correctNameExercise]).shuffled()
        
        try await batchInsert(allExercises, to: sut)
        
        try await expect(sut, toRetrievedWith: [correctNameExercise], with: .byName(name, sort: .none))
    }
    
    func test_retrieve_byName_deliversExercisesWithSimilarValidNameIgnoringCasesInAscendingOrder() async throws {
        let sut = makeSUT()
        let queryName = "any"
        let validExercises = ["\(queryName) name", "\(queryName) someting", "\(queryName) exercise", "\(queryName) name".uppercased()].map { anyExercise(name: $0) }
        let allExercises = (validExercises + makeExercises(count: 5)).shuffled()
        
        try await batchInsert(allExercises, to: sut)
        try await expect(sut, toRetrievedWith: validExercises.sortedByNameInAscendingOrder(), with: .byName(queryName, sort: .name(ascending: true)))
    }
    
    func test_retrieve_byName_deliversExercisesWithSimilarValidNameIgnoringCasesInDescendingOrder() async throws {
        let sut = makeSUT()
        let queryName = "any"
        let validExercises = ["\(queryName) test", "\(queryName) someting", "\(queryName) exercise", "\(queryName) name".uppercased()].map { anyExercise(name: $0) }
        let allExercises = (validExercises + makeExercises(count: 5)).shuffled()
        
        try await batchInsert(allExercises, to: sut)
        try await expect(sut, toRetrievedWith: validExercises.sortedByNameInDescendingOrder(), with: .byName(queryName, sort: .name(ascending: false)))
    }
    
    func test_retrieve_byCategory_deliversTheCorrectExerciseIgnoringCases() async throws {
        let sut = makeSUT()
        let category: BodyCategory = .abs
        let correctCategoryExercise = anyExercise(category: category)
        let allExercises = (makeExercises(count: 5) + [correctCategoryExercise]).shuffled()
        
        try await batchInsert(allExercises, to: sut)
        
        try await expect(sut, toRetrievedWith: [correctCategoryExercise], with: .byCategory(category, sort: .none))
    }
    
    func test_insert_wouldNotOverrideExistingValueInStore() async throws {
        let sut = makeSUT()
        let randomExercises = makeExercises(count: 5)
        
        try await batchInsert(randomExercises, to: sut)
        
        let newExercise = anyExercise(id: UUID())
        
        try await sut.insert(newExercise)
        
        let retrieved = try await sut.loadExercises(by: .all(sort: .none)).asCustomExercises()
        
        XCTAssertEqual(retrieved.count, 6)
        XCTAssertTrue(retrieved.contains(newExercise))
    }
    
    func test_delete_hasNoSideEffectsInEmptyStore() async throws {
        let sut = makeSUT()
        
        try await sut.delete(anyExercise())
        
        try await expect(sut, toRetrievedWith: [], with: .all(sort: .none))
    }
    
    func test_delete_deletesPreviouslyInsertedExerciseInStore() async throws {
        let sut = makeSUT()
        let exercise = anyExercise()
        
        try await sut.insert(exercise)
        try await sut.delete(exercise)
        
        try await expect(sut, toRetrievedWith: [], with: .all(sort: .none))
    }
    
    // Test if SwiftDataExerciseStore conform to ExerciseLoader
    func test_loadExercises_byAllQuery_returnsInsertedExercises() async throws {
        let schema = Schema([ExerciseEntity.self])
        let store = try! SwiftDataExerciseStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        let inserted = anyExercise()
        try await store.insert(inserted)
        
        let sut: ExerciseLoader = store
        let retrieved = try await sut.loadExercises(by: .all(sort: nil))
        
        let retrievedExercise = try XCTUnwrap(retrieved.first)
        XCTAssertEqual(retrievedExercise.id, inserted.id)
        XCTAssertEqual(retrievedExercise.category, inserted.category)
        XCTAssertEqual(retrievedExercise.name, inserted.name)
        XCTAssertEqual(retrievedExercise.isCustom, inserted.isCustom)
    }
    
    //MARK: - Helpers
    typealias ExerciseStore = ExerciseLoader & ExerciseInsertion & ExerciseDeletion
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ExerciseStore {
        let schema = Schema([ExerciseEntity.self])
        let sut = try! SwiftDataExerciseStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: ExerciseLoader, toRetrievedWith expected: [CustomExercise], with query: ExerciseQuery, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.loadExercises(by: query).asCustomExercises(file: file, line: line)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: ExerciseLoader, toRetrievedTwiceWith expected: [CustomExercise], with query: ExerciseQuery, file: StaticString = #file, line: UInt = #line) async throws {
        try await expect(sut, toRetrievedWith: expected, with: query, file: file, line: line)
        try await expect(sut, toRetrievedWith: expected, with: query, file: file, line: line)
    }
    
    private func batchInsert(_ exercises: [CustomExercise], to store: ExerciseInsertion) async throws {
        for exercise in exercises {
            try await store.insert(exercise)
        }
    }
    
    private func makeExercises(count: Int, category: BodyCategory = .other) -> [CustomExercise] {
        (0..<count).map { index in
            CustomExercise(
                id: UUID(),
                name: "exercise \(index)",
                category: category
            )
        }
    }
    
    private func makeMixedCategoryExercises() -> [CustomExercise] {
        [
            CustomExercise(id: UUID(), name: "Bench Press", category: .chest),
            CustomExercise(id: UUID(), name: "Deadlift", category: .back),
            CustomExercise(id: UUID(), name: "Squat", category: .legs),
            CustomExercise(id: UUID(), name: "Curls", category: .arms),
            CustomExercise(id: UUID(), name: "Overhead Press", category: .shoulder)
        ]
    }
}
