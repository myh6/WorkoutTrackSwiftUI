//
//  WorkoutDataManagerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import XCTest
import SwiftData
@testable import WorkoutTrack

@ModelActor
final actor SwiftDataWorkoutSessionStore {
    
    func retrieveSession() throws -> [WorkoutSessionDTO] {
        return []
    }
}

final class WorkoutDataStoreTests: XCTestCase {
    
    func test_retrieveSession_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveSession: [])
    }
    
    func test_retrieveSession_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveSessionTwice: [])
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SwiftDataWorkoutSessionStore {
        let schema = Schema([WorkoutSession.self])
        let sut = try! SwiftDataWorkoutSessionStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveSession expected: [WorkoutSessionDTO], file: StaticString = #file, line: UInt = #line) async throws {
        
        let retrieved = try await sut.retrieveSession()
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveSessionTwice expected: [WorkoutSessionDTO], file: StaticString = #file, line: UInt = #line) async throws {
        
        try await expect(sut, toRetrieveSession: expected, file: file, line: line)
        try await expect(sut, toRetrieveSession: expected, file: file, line: line)
    }
}
