//
//  SessionInsertionUseCasesTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//

import XCTest
import SwiftData
@testable import WorkoutTrack

final class WorkoutDataStoreInsertionUseCasesTests: WorkoutDataStoreTests {
    
    func test_insertSessionWithSameID_wouldNotCreateNewSessionButOverwirteTheExistingOne() async throws {
        let sut = makeSUT()
        let id = UUID()
        let firstInsertionSession = anySession(id: id, entries: [anyEntry()])
        let sessionWithSameID = anySession(id: id, entries: [anyEntry()])
        
        try await sut.insert(firstInsertionSession)
        try await sut.insert(sessionWithSameID)
        
        try await expect(sut, toRetrieve: [sessionWithSameID])
    }
    
    func test_insertSession_withFewerEntries_overwritesOldEntries() async throws {
        let sut = makeSUT()
        let entry = anyEntry()
        let presavedEntries = [entry, anyEntry()]
        let session = anySession(entries: presavedEntries)
        let newEntry = [entry]
        let sessionWithFewEntries = anySession(id: session.id, date: session.date, entries: newEntry)
        
        try await sut.insert(session)
        try await sut.insert(sessionWithFewEntries)
        
        try await expect(sut, toRetrieve: [sessionWithFewEntries])
        
    }
    
    func test_insert_toSameSession_wouldNotOverwriteExistingSessionAndItsEntries() async throws {
        let sut = makeSUT()
        let presavedEntry = anyEntry()
        let session = anySession(entries: [presavedEntry])
        let addedEntries = [anyEntry(createdAt: Date().adding(minutes: 1)), anyEntry(createdAt: Date().adding(minutes: -2))]
        
        try await sut.insert(session)
        try await sut.insert(addedEntries, to: session)
        
        try await expect(sut, toRetrieveEntry: ([presavedEntry] + addedEntries).sortedByDefaultOrder())
    }
    
    func test_insert_toNonExistantSession_createsSessionAndInsertsTheGivenEntries() async throws {
        let sut = makeSUT()
        let entry = anyEntry()
        let session = anySession()
        let expectedSession = appendingEntries([entry], to: session)
        
        try await sut.insert([entry], to: session)
        
        try await expect(sut, toRetrieve: [expectedSession])
    }
    
    func test_insertWithEntryAndSet_deliversFoundSessionWithPersistedEntryAndSet() async throws {
        let sut = makeSUT()
        let session = anySession(
            entries: [anyEntry(
                sets: [anySet()])])
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieve: [session])
    }
    
    func test_insertEntry_doesNotCreateDuplicationOnReinsertion() async throws {
        let sut = makeSUT()
        let entry = anyEntry()
        let session = anySession(entries: [entry])
        
        try await sut.insert(session)
        try await sut.insert([entry], to: session)
        
        try await expect(sut, toRetrieveEntry: [entry])
    }
    
    func test_insertSets_toNonExistingEntryDoesNothing() async throws {
        let sut = makeSUT()
        
        try await sut.insert([anySet()], to: anyEntry())
        
        try await expect(sut, toRetrieveEntry: [])
        try await expect(sut, toRetrieveSets: [])
    }
        
    func test_insertSets_toExistingEntryPersistsTheSetsAndDoesNotDuplicateEntry() async throws {
        let sut = makeSUT()
        let presavedSet = anySet()
        let entry = anyEntry(sets: [presavedSet])
        let newSet = anySet()
        
        try await sut.insert(anySession(entries: [entry]))
        try await sut.insert([newSet], to: entry)
        
        let expectedSet = [presavedSet, anySet(id: newSet.id, reps: newSet.reps, weight: newSet.weight, isFinished: newSet.isFinished, order: 1)]
        let expectedEntry = anyEntry(id: entry.id, exercise: entry.exerciseID, sets: expectedSet, createdAt: entry.createdAt, order: entry.order)
        
        try await expect(sut, toRetrieveEntry: [expectedEntry])
    }
    
    func test_insertSets_assignsOrderBasedOnExistingSetsCount() async throws {
        let sut = makeSUT()
        let entry = anyEntry(sets: [anySet(), anySet(), anySet()])
        let newSet = [anySet(), anySet()]
        
        try await sut.insert(anySession(entries: [entry]))
        try await sut.insert(newSet, to: entry)
        
        let retrievedOrder = try await retrievedOrder(from: sut)
        
        XCTAssertEqual(retrievedOrder, [0, 1, 2, 3, 4])
    }
    
    func test_insertSets_overwritesPreviousOrdersWithSequentialValues() async throws {
        let sut = makeSUT()
        let entry = anyEntry(sets: [anySet(order: 5), anySet(order: 10)])
        let session = anySession(entries: [entry])
        try await sut.insert(session)
        
        let newSets = [anySet(), anySet()]
        try await sut.insert(newSets, to: entry)
        
        let allOrders = try await retrievedOrder(from: sut)
        
        XCTAssertEqual(allOrders, [0, 1, 2, 3])
    }
    
    func test_insertSets_doesNotCreateDuplcicateSetsOnReinsertion() async throws {
        let sut = makeSUT()
        let sets = [anySet(order: 0), anySet(order: 1)]
        let entry = anyEntry(sets: sets)
        let session = anySession(entries: [entry])
        try await sut.insert(session)
        
        try await sut.insert(sets, to: entry)
        
        try await expect(sut, toRetrieveSets: sets)
    }
    
    
    //MARK: - Helpers
    private func appendingEntries(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: session.id, date: session.date, entries: session.entries + entries)
    }
    
    private func retrievedOrder(from sut: SwiftDataWorkoutSessionStore, with query: SessionQueryDescriptor? = nil) async throws -> [Int] {
        return try await sut.retrieve(query: query).flatMap(\.entries).flatMap(\.sets).map(\.order)
    }
}
