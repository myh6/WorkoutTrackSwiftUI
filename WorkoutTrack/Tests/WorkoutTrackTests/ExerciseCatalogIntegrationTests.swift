//
//  ExerciseCatalogIntegrationTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/15.
//

import XCTest
@testable import WorkoutTrack
import SwiftData

class DefaultExerciseCatalog: ExerciseLoader {
    let loaders: [ExerciseLoader]
    let store: ExerciseStore
    
    init(loaders: [ExerciseLoader], store: ExerciseStore) {
        self.loaders = loaders
        self.store = store
    }
    
    func loadExercises(by query: ExerciseQuery) async throws -> [any DisplayableExercise] {
        var loaded: [any DisplayableExercise] = []
        
        for loader in loaders {
            let output = try await loader.loadExercises(by: query)
            loaded.append(contentsOf: output)
        }
        
        return loaded
    }
}

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
        
        try await sut.store.insert(custom)
        let loaded = try await sut.loadExercises(by: .all(sort: .none)).map(\.id)
        
        XCTAssertTrue(loaded.contains(custom.id))
        XCTAssertEqual(loaded.count, presaved.count + 1)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> DefaultExerciseCatalog {
        let container = try! ModelContainer(for: Schema([ExerciseEntity.self]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let store = SwiftDataExerciseStore(modelContainer: container)
        let presaved = PresavedExercisesLoader()
        
        return DefaultExerciseCatalog(loaders: [presaved, store], store: store)
    }
    
    private func getAllPresavedExercises() async throws -> [DisplayableExercise] {
        return try await PresavedExercisesLoader().loadExercises(by: .all(sort: .none))
    }
    
    private func anyExercise(id: UUID = UUID(), name: String = "any name", category: BodyCategory = .abs) -> CustomExercise {
        return CustomExercise(id: id, name: name, category: category)
    }
}
