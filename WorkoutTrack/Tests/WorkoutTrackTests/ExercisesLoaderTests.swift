//
//  ExercisesLoaderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/22.
//

import XCTest

struct Exercise {
    let nameKey: String
    let categoryKey: String
}

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

protocol UserExerciseRepository {
    func fetchExercises() -> [Exercise]
}

struct CustomSavedExercisesLoader {
    let repository: UserExerciseRepository
    
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
        let mock = MockExercisesRepo()
        let loader = CustomSavedExercisesLoader(repository: mock)
        
        _ = loader.getAllExercises()
        
        XCTAssertEqual(mock.fetchExercisesCallCount, 1)
    }
    
    //MARK: - Helpers
    private class MockExercisesRepo: UserExerciseRepository {
        private(set) var fetchExercisesCallCount = 0
        
        func fetchExercises() -> [Exercise] {
            fetchExercisesCallCount += 1
            return []
        }
    }


}
