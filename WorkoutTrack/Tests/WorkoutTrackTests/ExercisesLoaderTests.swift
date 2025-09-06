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

struct CustomSavedExercisesLoader {
    
}

final class ExercisesLoaderTests: XCTestCase {
    
    //MARK: Pre-saved
    
    func test_presavedLoader_returnsKnownPresavedExercises() {
        let loader = PresavedExercisesLoader()
        let exercises = loader.getAllExercises()
        
        XCTAssertEqual(exercises.count, 1)
    }
    

}
