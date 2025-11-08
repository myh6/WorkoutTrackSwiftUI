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
    
    func test_updateEntry_doesNotChangeOrderValueWhenThereIsOnlyOneEntry() async throws {
        let sut = makeSUT()
        
        let sessionId = UUID()
        let entryId = UUID()
        let newExerciseId = UUID()
        
        let savedSession = anySession(id: sessionId, entries: [
            anyEntry(id: entryId, exercise: UUID(), order: 0)
        ])
        
        try await sut.insert(savedSession)
        
        // Should not update the order when there's only one entry within a session
        let updatedEntry = anyEntry(id: entryId, exercise: newExerciseId, order: 1)
        try await sut.update(updatedEntry, withinSession: sessionId)
        
        let result = try await retrieveEntry(from: sut)
        let retrievedEntry = try XCTUnwrap(result.first)
        XCTAssertEqual(retrievedEntry.id, entryId)
        XCTAssertEqual(retrievedEntry.exerciseID, newExerciseId)
        XCTAssertEqual(retrievedEntry.order, 0)
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
    
    func test_updateSet_updatesAllOthersOrderValueWhenUpdatingOrder() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        let entryId = UUID()
        let setId = UUID()
        
        let setA = anySet(order: 0)
        let setB = anySet(order: 1)
        let setC = anySet(id: setId, order: 2)
        
        try await sut.insert(anySession(id: sessionId, entries: [
            anyEntry(id: entryId, sets: [
                setA, setB, setC
            ])
        ]))
        
        let updatedSet = anySet(id: setId, order: 0)
        
        try await sut.update(updatedSet, withinEntry: entryId)
        // Set A & Set B should automatically adjust its order value
        let newSetA = anySet(id: setA.id, reps: setA.reps, weight: setA.weight, isFinished: setA.isFinished, order: 1)
        let newSetB = anySet(id: setB.id, reps: setB.reps, weight: setB.weight, isFinished: setB.isFinished, order: 2)
        
        let allOrders = try await retrieveSetOrder(from: sut)
        XCTAssertEqual(allOrders, [0, 1, 2])
        try await expect(sut, toRetrieveSets: [updatedSet, newSetA, newSetB])
    }
    
    func test_updateSet_doesNotChangeOrderValueWhenThereIsOnlyOneSet() async throws {
        let sut = makeSUT()
        
        let entryId = UUID()
        let setId = UUID()
        
        let savedSession = anySession(entries: [anyEntry(id: entryId, sets: [anySet(id: setId, isFinished: false, order: 0)])])
        
        try await sut.insert(savedSession)
        
        // Change the order to 1 (default is 0)
        let updatedSet = anySet(id: setId, isFinished: true, order: 1)
        
        try await sut.update(updatedSet, withinEntry: entryId)
        // Should still be zero (zero-index based)
        let result = try await retrieveSet(from: sut)
        let retrievedSet = try XCTUnwrap(result.first)
        XCTAssertEqual(retrievedSet.id, setId)
        XCTAssertEqual(retrievedSet.isFinished, true)
        XCTAssertEqual(retrievedSet.order, 0)
    }
    
    //MARK: - Helpers
    private func retrieveEntry(from sut: SwiftDataWorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [WorkoutEntryDTO] {
        return try await sut.retrieve(query: query).flatMap(\.entries)
    }
    
    private func retrieveEntryOrder(from sut: SwiftDataWorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [Int] {
        return try await retrieveEntry(from: sut, with: query).map(\.order)
    }
    
    private func retrieveSet(from sut: SwiftDataWorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [WorkoutSetDTO] {
        return try await retrieveEntry(from: sut, with: query).flatMap(\.sets)
    }
    
    private func retrieveSetOrder(from sut: SwiftDataWorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [Int] {
        return try await retrieveSet(from: sut, with: query).map(\.order)
    }
}
