//
//  XCTestCase+MemoryLeakTracking.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/6/25.
//

import XCTest

extension XCTestCase {
    @MainActor
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock {
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
