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

class CustomSavedExercisesLoader {
    private let repository: UserExerciseRepository
    
    init(repository: UserExerciseRepository) {
        self.repository = repository
    }
    
    func getAllExercises() -> [Exercise] {
        return repository.fetchExercises()
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
        
        XCTAssertEqual(mock.fetchExercisesCallCount, 1)
    }
    
    func test_customLoader_returnsExercisesFetchedFromRepository() {
        let anyExercise = [anyExercise()]
        let (loader, _) = makeLoader(with: anyExercise)
        
        XCTAssertEqual(loader.getAllExercises(), anyExercise)
    }
    
    //MARK: - Helpers
    private class MockExercisesRepo: UserExerciseRepository {
        private var stubbed: [Exercise]
        private(set) var fetchExercisesCallCount = 0
        
        init(stubbed: [Exercise] = []) {
            self.stubbed = stubbed
        }
        
        func stub(_ exercises: [Exercise]) {
            self.stubbed = exercises
        }
        
        func fetchExercises() -> [Exercise] {
            fetchExercisesCallCount += 1
            return stubbed
        }
    }
    
    private func makeLoader(with stubbedExercises: [Exercise] = [], file: StaticString = #file, line: UInt = #line) -> (loader: CustomSavedExercisesLoader, repo: MockExercisesRepo) {
        let mock = MockExercisesRepo(stubbed: stubbedExercises)
        let loader = CustomSavedExercisesLoader(repository: mock)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(mock, file: file, line: line)
        return (loader, mock)
    }
    
    private func anyExercise() -> Exercise {
        return Exercise(nameKey: "any name key", categoryKey: "any category key")
    }

}
