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

@ModelActor
final actor SwiftDataExerciseStore {
    func retrieve() throws -> [CustomExercise] {
        return []
    }
}


final class SwiftDataExerciseStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        let retrieved = try await sut.retrieve()
        
        XCTAssertEqual(retrieved, [])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        let firstRetrieved = try await sut.retrieve()
        let secondRetrieved = try await sut.retrieve()
        
        XCTAssertEqual(firstRetrieved, secondRetrieved)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SwiftDataExerciseStore {
        let schema = Schema([ExerciseEntity.self])
        let sut = try! SwiftDataExerciseStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut)
        return sut
    }
}
