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
    
    func test_updateEntry_updatesAllOtherOrdersWhenUpdatingOrderValue() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        let entryId = UUID()
        let entryA = anyEntry(order: 0)
        let entryB = anyEntry(order: 1)
        let entryC = anyEntry(id: entryId, order: 2)
        
        let descriptor = QueryBuilder()
            .sort(by: .entryCustomOrder)
            .build()
        
        try await sut.insert(anySession(id: sessionId, entries: [
            entryA, entryB, entryC
        ]))
        
        let updatedEntry = anyEntry(id: entryId, order: 0)
        
        try await sut.update(updatedEntry, withinSession: sessionId)
        // Entry A & Entry B should automatically adjust its order value
        let newEntryA = anyEntry(id: entryA.id, exercise: entryA.exerciseID, sets: entryA.sets, createdAt: entryA.createdAt, order: 1)
        let newEntryB = anyEntry(id: entryB.id, exercise: entryB.exerciseID, sets: entryB.sets, createdAt: entryB.createdAt, order: 2)
        
        let allOrders = try await retrieveEntryOrder(from: sut, with: descriptor)
        XCTAssertEqual(allOrders, [0, 1, 2])
        try await expect(sut, toRetrieveEntry: [updatedEntry, newEntryA, newEntryB], withQuery: descriptor)
    }
    
    func test_updateSet_hasNoEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.update(anySet())
        
        try await expect(sut, toRetrieveSets: [])
    }
    
    func test_updateSet_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await sut.update(anySet())
        try await sut.update(anySet())
        
        try await expect(sut, toRetrieveSets: [])
    }
    
    //MARK: - Helpers
    private func retrieveEntryOrder(from sut: SwiftDataWorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [Int] {
        return try await sut.retrieve(query: query).flatMap(\.entries).map(\.order)
    }
}
