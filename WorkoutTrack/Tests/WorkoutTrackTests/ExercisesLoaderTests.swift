//
//  ExercisesLoaderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/22.
//

import XCTest
@testable import WorkoutTrack

final class PresavedExercisesLoaderTests: XCTestCase {
    
    func test_loader_returnsAllExercises() throws {
        let loader = PresavedExercisesLoader()
        let all = try loader.getAllExercises()
        XCTAssertEqual(all.count, 110)
    }

}
