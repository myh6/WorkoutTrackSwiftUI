//
//  ExerciseSystemIntegrationTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/15.
//

import XCTest
@testable import WorkoutTrack
import SwiftData

final class ExerciseCatalogIntegrationTests: XCTestCase {
    
    func test_loadExercises_deliversAllPresavedExercisesOnEmptyStore() async throws {
        let sut = makeSUT()
        
        let loaded = try await sut.loadExercises(by: .all(sort: .none))
        let expected = try await getAllPresavedExercises().map(\.id).sorted()
        
        XCTAssertEqual(loaded.map(\.id).sorted(), expected)
    }
    
    func test_loadExercises_deliversPresavedAndCustomExercisesFromStore() async throws {
        let sut = makeSUT()
        let custom = anyExercise(id: UUID(), name: "Test curl", category: .arms)
        let presaved = try await getAllPresavedExercises()
        
        try await sut.addExercise(custom)
        let loaded = try await sut.loadExercises(by: .all(sort: .none)).map(\.id)
        
        XCTAssertTrue(loaded.contains(custom.id))
        XCTAssertEqual(loaded.count, presaved.count + 1)
    }
    
    func test_loadExercises_respectsSortOrder() async throws {
        let sut = makeSUT()
        
        let first = anyExercise(name: "Alpha", category: .chest)
        let second = anyExercise(name: "Zeta", category: .abs)
        
        try await sut.addExercise(first)
        try await sut.addExercise(second)
        
        let loadedName = try await sut.loadExercises(by: .onlyCustom(sort: .name(ascending: true))).map(\.name)

        XCTAssertEqual(loadedName, ["Alpha", "Zeta"])
        
        let loadedCategory = try await sut.loadExercises(by: .onlyCustom(sort: .category(ascending: true))).map(\.category)
        
        XCTAssertEqual(loadedCategory, ["Abs", "Chest"])
    }
    
    func test_loadExercise_onlyCustom_deliversNoPresavedExercise() async throws {
        let sut = makeSUT()
        let custom = anyExercise(id: UUID(), name: "Test curl", category: .arms)
        
        try await sut.addExercise(custom)
        let loaded = try await sut.loadExercises(by: .onlyCustom(sort: .none))
        
        XCTAssertEqual(loaded.count, 1)
        let retrievedExercise = try XCTUnwrap(loaded.first)
        XCTAssertEqual(retrievedExercise.id, custom.id)
        XCTAssertEqual(retrievedExercise.name, custom.name)
        XCTAssertEqual(retrievedExercise.category, custom.category)
    }
    
    func test_addExercise_persistsExerciseInStore() async throws {
        let sut = makeSUT()
        let custom = anyExercise()

        try await sut.addExercise(custom)
        let loaded = try await sut.loadExercises(by: .onlyCustom(sort: .none))

        XCTAssertTrue(loaded.contains(where: { $0.id == custom.id }))
    }
    
    func test_removeExercise_deletesExerciseFromStore() async throws {
        let sut = makeSUT()
        let custom = anyExercise()
        
        try await sut.addExercise(custom)
        try await sut.removeExercise(custom)
        
        let loaded = try await sut.loadExercises(by: .onlyCustom(sort: .none))
        XCTAssertTrue(loaded.isEmpty)
    }
    
    func test_updateExercise_modifiesCustomExercise() async throws {
        let sut = makeSUT()
        let exercise = anyExercise(name: "random exercise")
        let updatedExdercise = anyExercise(id: exercise.id, name: "Updated exercise", category: .glutes)
        
        try await sut.addExercise(exercise)
        try await sut.updateExercise(updatedExdercise)
        
        let loaded = try await sut.loadExercises(by: .onlyCustom(sort: .none))
        let first = try XCTUnwrap(loaded.first)
        XCTAssertEqual(first.name, updatedExdercise.name)
        XCTAssertEqual(first.category, updatedExdercise.category)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> ExerciseSystem {
        let container = try! ModelContainer(for: Schema([ExerciseEntity.self]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let store = SwiftDataExerciseStore(modelContainer: container)
        let presaved = PresavedExercisesLoader()
        
        return DefaultExerciseSystem(loaders: [presaved, store], io: store)
    }
    
    private func getAllPresavedExercises() async throws -> [DisplayableExercise] {
        return try await PresavedExercisesLoader().loadExercises(by: .all(sort: .none))
    }
}
