//
//  ExercisesLoaderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/22.
//

import XCTest
import WorkoutTrack

protocol ExercisesLoader {
    func getAllExercises() -> [Exercise]
}

struct PresavedExercisesLoader {
    func getAllExercises() -> [Exercise] {
        return [
            Exercise(nameKey: "exercise.name.back_squat", categoryKey: "exercise.category.legs"),
        ]
    }
}

final class ExercisesLoaderTests: XCTestCase {
    
    //MARK: Pre-saved
    
    func test_presavedLoader_returnsKnownPresavedExercises() {
        let loader = PresavedExercisesLoader()
        let exercises = loader.getAllExercises()
        
        XCTAssertEqual(exercises.count, 1)
    }
    
    //MARK: Custom Saved
    
    func test_customLoader_callsRepositoryToFetchExercises() {
        let (loader, mock) = makeLoader()
        
        _ = loader.getAllExercises()
        
        XCTAssertEqual(mock.retrieveCallCount, 1)
    }
    
    func test_customLoader_returnsExercisesFetchedFromStore() {
        let anyExercise = [anyExercise()]
        let (loader, _) = makeLoader(with: anyExercise)
        
        XCTAssertEqual(loader.getAllExercises(), anyExercise)
    }
    
    //MARK: - Helpers
    private class MockExercisesStore: ExerciseStore {
        private(set) var retrieveCallCount: Int = 0
        private var stubbed: [Exercise]
        
        init(stubbed: [Exercise]) {
            self.stubbed = stubbed
        }
        
        func retrieve() -> [Exercise] {
            retrieveCallCount += 1
            return stubbed
        }
    }
    
    private func makeLoader(with stubbedExercises: [Exercise] = [], file: StaticString = #file, line: UInt = #line) -> (loader: CustomSavedExercisesLoader, repo: MockExercisesStore) {
        let mock = MockExercisesStore(stubbed: stubbedExercises)
        let loader = CustomSavedExercisesLoader(store: mock)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(mock, file: file, line: line)
        return (loader, mock)
    }
    
    private func anyExercise() -> Exercise {
        return Exercise(nameKey: "any name key", categoryKey: "any category key")
    }

}
