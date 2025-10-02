//
//  SwiftDataExerciseStoreTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/9/29.
//

import XCTest
import WorkoutTrack
import SwiftData

@Model
final class ExerciseEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    
    init(id: UUID, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
}

extension ExerciseEntity {
    var model: CustomExercise {
        .init(id: id, name: name, category: category)
    }
}

extension Array where Element == ExerciseEntity {
    func toModels() -> [CustomExercise] {
        map(\.model)
    }
}

@ModelActor
final actor SwiftDataExerciseStore {
    func retrieve() throws -> [CustomExercise] {
        let descriptor = FetchDescriptor<ExerciseEntity>()
        return try modelContext.fetch(descriptor).toModels()
    }
    
    func insert(_ exercise: CustomExercise) {
        let entity = ExerciseEntity(id: exercise.id, name: exercise.name, category: exercise.category)
        modelContext.insert(entity)
    }
}


final class SwiftDataExerciseStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveExercises: [])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveExercisesTwice: [])
    }
    
    func test_retrieve_deliversFoundExercisesOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let anyExercise = anyExercise()
        
        await sut.insert(anyExercise)
        
        try await expect(sut, toRetrieveExercises: [anyExercise])
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SwiftDataExerciseStore {
        let schema = Schema([ExerciseEntity.self])
        let sut = try! SwiftDataExerciseStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: SwiftDataExerciseStore, toRetrieveExercises expected: [CustomExercise], file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieve()
        
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataExerciseStore, toRetrieveExercisesTwice expected: [CustomExercise], file: StaticString = #file, line: UInt = #line) async throws {
        try await expect(sut, toRetrieveExercises: expected, file: file, line: line)
        try await expect(sut, toRetrieveExercises: expected, file: file, line: line)
    }
    
    private func anyExercise(id: UUID = UUID(), name: String = "any exercise", category: String = "any category") -> CustomExercise {
        CustomExercise(id: id, name: name, category: category)
    }
}
