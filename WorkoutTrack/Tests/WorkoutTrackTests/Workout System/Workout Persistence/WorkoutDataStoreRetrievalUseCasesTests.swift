//
//  WorkoutDataManagerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import XCTest
@testable import WorkoutTrack

final class WorkoutDataStoreRetrievalUseCasesTests: WorkoutDataStoreTests {
    
    func test_retrieve_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieve: [])
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveTwice: [])
    }
    
    func test_retrieve_deliversFoundSessionOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let session = anySession()
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieve: [session])
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let session = anySession()
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieveTwice: [session])
    }
}
