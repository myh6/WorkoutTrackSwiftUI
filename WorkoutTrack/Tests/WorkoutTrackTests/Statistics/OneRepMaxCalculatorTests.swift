//
//  OneRepMaxCalculatorTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/12.
//

import XCTest
import WorkoutTrack

struct OneRepMaxCalculator {
    static func getBestOneRepMax(for exercise: UUID, from data: [WorkoutSessionDTO]) -> Double? {
        return nil
    }
}

final class OneRepMaxCalculatorTests: XCTestCase {
    
    func test_getBestOneRepMax_returnsNilWhenNoData() {
        let result = OneRepMaxCalculator.getBestOneRepMax(for: UUID(), from: [])
        XCTAssertNil(result)
    }
}
