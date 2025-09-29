//
//  LocalizedExerciseTests.swift
//  WorkoutTrackTests
//
//  Created by Assistant on 9/28/25.
//

import XCTest
@testable import WorkoutTrack

final class LocalizedExerciseConformanceTests: XCTestCase {
    func test_compilesAsDisplayableExercise() {
        func acceptsDisplayable(_ v: any DisplayableExercise) {}
        let sut = LocalizedExercise(nameKey: "exercise.name.back_squat", categoryKey: "exercise.category.legs")
        acceptsDisplayable(sut)
    }
}

final class LocalizedExerciseLocalizationTests: XCTestCase {
    func test_nameAndCategoryLocalizeFromExercisesTable() {
        let sut = LocalizedExercise(nameKey: "exercise.name.back_squat", categoryKey: "exercise.category.legs")
        let name = sut.name
        let category = sut.category
        
        XCTAssertNotEqual(name, sut.nameKey)
        XCTAssertNotEqual(category, sut.categoryKey)
    }
}

final class LocalizedExerciseIDTests: XCTestCase {
    func test_sameKeysYieldSameDeterministicID() {
        let a = LocalizedExercise(nameKey: "exercise.name.back_squat", categoryKey: "exercise.category.legs")
        let b = LocalizedExercise(nameKey: "exercise.name.back_squat", categoryKey: "exercise.category.legs")
        XCTAssertEqual(a.id, b.id)
    }

    func test_differentKeysYieldDifferentDeterministicID() {
        let a = LocalizedExercise(nameKey: "exercise.name.back_squat", categoryKey: "exercise.category.legs")
        let b = LocalizedExercise(nameKey: "exercise.name.bench_press", categoryKey: "exercise.category.chest")
        XCTAssertNotEqual(a.id, b.id)
    }
}
