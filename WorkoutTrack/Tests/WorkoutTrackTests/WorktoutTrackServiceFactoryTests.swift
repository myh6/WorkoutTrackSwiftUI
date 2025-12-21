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
    
    func test_factory_persistentStore_persistsAcrossFactoryInstances() async throws {
        let storeURL = try makeTemporaryStoreURL()
        addTeardownBlock {
            try? Self.removeStoreArtifacts(at: storeURL)
        }
        
        let custom = anyExercise(name: "Random Exercise")
        
        do {
            let factoryA = try WorkoutTrackServiceFactory(storage: .persistent, storeURL: storeURL)
            let serviceA = factoryA.makeService()
            try await serviceA.addCustomExercise(custom)
        }
        do {
            let factoryB = try WorkoutTrackServiceFactory(storage: .persistent, storeURL: storeURL)
            let serviceB = factoryB.makeService()
            let retrieved = try await serviceB.getExerciseName(from: custom.id)
            XCTAssertEqual(retrieved, custom.name)
        }
    }
    
    private func makeTemporaryStoreURL() throws -> URL {
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("WorkoutTrackTests", isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        return temporaryDirectory.appendingPathComponent("WorkoutTrack.sqlite")
    }
    
    private static func removeStoreArtifacts(at storeURL: URL) throws {
        let fm = FileManager.default
        try? fm.removeItem(at: storeURL)

        let sidecars = [
            storeURL.appendingPathExtension("shm"),
            storeURL.appendingPathExtension("wal"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        ]
        for url in sidecars {
            try? fm.removeItem(at: url)
        }

        try? fm.removeItem(at: storeURL.deletingLastPathComponent())
    }
}
