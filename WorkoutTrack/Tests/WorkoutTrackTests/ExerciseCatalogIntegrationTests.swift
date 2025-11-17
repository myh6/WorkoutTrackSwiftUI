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
    
    init(loaders: [ExerciseLoader]) {
        self.loaders = loaders
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
        
        let expected = try await PresavedExercisesLoader().loadExercises(by: .all(sort: .none))
        
        XCTAssertEqual(loaded.map(\.id).sorted(), expected.map(\.id).sorted())
    }
    
    //MARK: - Helpers
    private func makeSUT() -> DefaultExerciseCatalog {
        let container = try! ModelContainer(for: Schema([ExerciseEntity.self]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let store = SwiftDataExerciseStore(modelContainer: container)
        let presaved = PresavedExercisesLoader()
        
        return DefaultExerciseCatalog(loaders: [presaved, store])
    }
}
