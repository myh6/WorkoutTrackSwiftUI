//
//  WorkoutDataStoreDeletionUseCasesTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//

import XCTest
@testable import WorkoutTrack

final class WorkoutDataStoreDeletionUseCasesTests: WorkoutDataStoreTests {
    
    func test_deleteSession_hasNoEffectOnEmptyDatabase() async {
        let sut = makeSUT()
        
        do {
            try await sut.delete(anySession())
        } catch {
            XCTFail("Expected SUT to delete without any error on empty database")
        }
    }
    
    func test_deleteSession_hasNoEffectOnNonExistantSession() async throws {
        let sut = makeSUT()
        let session = anySession()
        try await sut.insert(session)
        
        try await sut.delete(anySession())
        try await expect(sut, toRetrieve: [session])
    }
    
    func test_deleteSession_deletesTheSpecificedSessionAndItsEntry() async throws {
        let sut = makeSUT()
        let session = anySession(entries: [anyEntry(), anyEntry(), anyEntry()])
        
        try await sut.insert(session)
        try await sut.delete(session)
        
        try await expect(sut, toRetrieveEntry: [])
    }
    
    func test_deleteEntry_hasNoEffectsOnEmptyDatabase() async {
        let sut = makeSUT()
        
        do {
            try await sut.delete(anyEntry())
        } catch {
            XCTFail("Expected SUT to delete without any error on non existant entry")
        }
    }
    
    func test_deleteEntry_hasNoSideEffectsOnNonExistantEntry() async throws {
        let sut = makeSUT()
        let entry = anyEntry()
        try await sut.insert(anySession(entries: [entry]))
        
        try await sut.delete(anyEntry())
        try await expect(sut, toRetrieveEntry: [entry])
    }
    
    func test_deleteEntry_deletesTheSpecificedEntryAndItsSets() async throws {
        let sut = makeSUT()
        let entry = anyEntry(sets: [anySet(), anySet()])
        
        try await sut.insert(anySession(entries: [entry]))
        try await sut.delete(entry)
        
        try await expect(sut, toRetrieveEntry: [])
        try await expect(sut, toRetrieveSets: [])
    }
    
    func test_deleteSet_hasNoEffectsOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        do {
            try await sut.delete(anySet())
        } catch {
            XCTFail("Expected SUT to delete without any error on non existant set")
        }
    }
    
    func test_deleteSet_hasNoEffectsOnNonExistantSet() async throws {
        let sut = makeSUT()
        let set = anySet()
        try await sut.insert(anySession(entries: [anyEntry(sets: [set])]))
        
        try await sut.delete(anySet())
        try await expect(sut, toRetrieveSets: [set])
    }
    
    func test_deleteSet_deletesTheSpecificedSet() async throws {
        let sut = makeSUT()
        let set = anySet()
        let deleteSet = anySet()
        let entry = anyEntry(sets: [set, deleteSet])
        
        try await sut.insert(anySession(entries: [entry]))
        try await sut.delete(deleteSet)
        
        try await expect(sut, toRetrieveSets: [set])
    }
}
