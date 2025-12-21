//
//  WorktoutTrackServiceFactoryTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import XCTest
import WorkoutTrack

final class WorkoutTrackServiceFactoryTests: XCTestCase {
    
    func test_factory_createsMultipleServices_thatShareSamePersistence() async throws {
        let factory = try WorkoutTrackServiceFactory(storage: .inMemory)
        let serviceA = factory.makeService()
        let serviceB = factory.makeService()
        
        let custom = anyExercise(name: "Random exercise")
        try await serviceA.addCustomExercise(custom)
        
        let retrieved = try await serviceB.getExerciseName(from: custom.id)
        XCTAssertEqual(retrieved, custom.name)
    }
    
}
