//
//  CustomExercise+Array.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/3.
//

@testable import WorkoutTrack
import XCTest

extension Array where Element == DisplayableExercise {
    func asCustomExercises(file: StaticString = #file, line: UInt = #line) -> [CustomExercise] {
        let casted = self.compactMap { $0 as? CustomExercise }
        XCTAssertEqual(casted.count, self.count, "Failed to cast all elements to CustomExercise", file: file, line: line)
        return casted
    }
}

extension Array where Element == CustomExercise {
    func sortedByNameInAscendingOrder() -> [CustomExercise] {
        sorted { $0.name.ignoringCase() < $1.name.ignoringCase() }
    }
    
    func sortedByNameInDescendingOrder() -> [CustomExercise] {
        sorted { $0.name.ignoringCase() > $1.name.ignoringCase() }
    }
    
    func sortedByCategoryInAscendingOrder() -> [CustomExercise] {
        sorted { $0.category < $1.category }
    }
    
    func sortedByCategoryInDescendingOrder() -> [CustomExercise] {
        sorted { $0.category > $1.category }
    }
}

extension String {
    func ignoringCase() -> String {
        return self.lowercased()
    }
}
