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
        
        try await sut.update(anySession())
        
        try await expect(sut, toRetrieve: [])
    }
    
    func test_updateSession_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.update(anySession())
        try await sut.update(anySession())

        try await expect(sut, toRetrieve: [])
    }
    
    func test_updateSession_updatesExistingSession() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        
        try await sut.insert(anySession(id: sessionId, date: Date.distantPast, entries: [anyEntry(sets: [anySet()])]))
        
        let updatedSession = anySession(id: sessionId, entries: [anyEntry(sets: [anySet()])])
        
        try await sut.update(updatedSession)
        
        try await expect(sut, toRetrieve: [updatedSession])
    }
    
    func test_updateEntry_hasNoEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.update(anyEntry(), withinSession: UUID())
        
        try await expect(sut, toRetrieveEntry: [])
    }
    
    func test_updateEntry_hasNoSideEffectOnEmptyDatabae() async throws {
        let sut = makeSUT()
        
        try await sut.update(anyEntry(), withinSession: UUID())
        try await sut.update(anyEntry(), withinSession: UUID())
        
        try await expect(sut, toRetrieveEntry: [])
    }
    
    func test_updateEntry_doesNothingToNonExistingSession() async throws {
        let sut = makeSUT()
        let savedSession = anySession()
        
        try await sut.insert(savedSession)
        try await sut.update(anyEntry(), withinSession: UUID())
        
        try await expect(sut, toRetrieve: [savedSession])
        try await expect(sut, toRetrieveEntry: [])
    }
    
    func test_updateEntry_doesNothingToNonExistingEntry() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        let savedSession = anySession(id: sessionId, entries: [anyEntry()])
        
        try await sut.insert(savedSession)
        try await sut.update(anyEntry(), withinSession: sessionId)
        
        try await expect(sut, toRetrieve: [savedSession])
    }
    
    func test_updateEntry_updatesExistingEntry() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        let entryId = UUID()
        let otherEntry = anyEntry(createdAt: Date().adding(seconds: -1))
        
        try await sut.insert(anySession(id: sessionId, entries: [
            otherEntry,
            anyEntry(id: entryId, sets: [anySet()])
        ]))
        
        let updatedEntry = anyEntry(id: entryId, exercise: UUID(), sets: [anySet(order: 0), anySet(order: 1)], createdAt: Date().adding(seconds: 10), order: 1)
        
        try await sut.update(updatedEntry, withinSession: sessionId)
        
        try await expect(sut, toRetrieveEntry: [otherEntry, updatedEntry].sortedByDefaultOrder())
    }
    
    func test_updateSet_hasNoEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.update(anySet(), withinEntry: UUID())
        
        try await expect(sut, toRetrieveSets: [])
    }
    
    func test_updateSet_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.update(anySet(), withinEntry: UUID())
        try await sut.update(anySet(), withinEntry: UUID())
        
        try await expect(sut, toRetrieveSets: [])
    }
    
    func test_updateSet_doesNothingToNonExistingSet() async throws {
        let sut = makeSUT()
        let entryID = UUID()
        let savedSession = anySession(entries: [anyEntry(id: entryID, sets: [anySet()])])
        try await sut.insert(savedSession)
        try await sut.update(anySet(), withinEntry: entryID)
        
        try await expect(sut, toRetrieve: [savedSession])
    }
    
    func test_updateSet_doesNothingToNonExisitingEntry() async throws {
        let sut = makeSUT()
        let savedSession = anySession(entries: [anyEntry()])
        try await sut.insert(savedSession)
        try await sut.update(anySet(), withinEntry: UUID())
        
        try await expect(sut, toRetrieve: [savedSession])
    }
    
    func test_updateSet_updatesExistingSet() async throws {
        let sut = makeSUT()
        let setId = UUID()
        let entryId = UUID()
        
        let entry = anyEntry(id: entryId, sets: [
            anySet(id: setId)
        ])
        let session = anySession(entries: [entry])
        
        try await sut.insert(session)
        
        let updatedSet = anySet(id: setId, weight: 10, isFinished: true)
        try await sut.update(updatedSet, withinEntry: entryId)
        
        try await expect(sut, toRetrieveSets: [updatedSet])
    }
    
    //MARK: - Helpers
    private func retrieveEntry(from sut: WorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [WorkoutEntryDTO] {
        return try await sut.retrieve(query: query).flatMap(\.entries)
    }
    
    private func retrieveEntryOrder(from sut: WorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [Int] {
        return try await retrieveEntry(from: sut, with: query).map(\.order)
    }
    
    private func retrieveSet(from sut: WorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [WorkoutSetDTO] {
        return try await retrieveEntry(from: sut, with: query).flatMap(\.sets)
    }
    
    private func retrieveSetOrder(from sut: WorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [Int] {
        return try await retrieveSet(from: sut, with: query).map(\.order)
    }
}
