//
//  WorkoutDataStoreUpdateUseCasesTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/3.
//

import XCTest
@testable import WorkoutTrack

final class WorkoutDataStoreUpdateUseCasesTests: WorkoutDataStoreTests {
    
    func test_updateSession_hasNoEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        await sut.update(anySession())
        
        try await expect(sut, toRetrieve: [])
    }
    
}
