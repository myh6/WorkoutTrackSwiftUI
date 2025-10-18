//
//  WorkoutDataManagerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import XCTest
import SwiftData
@testable import WorkoutTrack


final class WorkoutDataStoreTests: XCTestCase {
    
    func test_retrieveSession_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveSession: [])
    }
    
    func test_retrieveSession_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveSessionTwice: [])
    }
    
    func test_retrieveSession_all_deliversFoundSessionOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let session = anySession()
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieveSession: [session], withQuery: .all(sort: nil))
    }
    
    func test_retrieveSession_hasNoSideEffectOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let session = anySession()
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieveSessionTwice: [session])
    }
    
    func test_retrieveSession_allSortedBySessionID_deliversFoundSessionInSortedOrder() async throws {
        let sut = makeSUT()
        let allID = [UUID(), UUID(), UUID()]
        let allSessions = allID.map { anySession(id: $0) }
        
        for session in allSessions {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSessions.sortedBySessionInAscendingOrder(), withQuery: .all(sort: .bySessionId(ascending: true)))
    }
    
    func test_retrieveSession_allSortedBySessionIdInReverse_deliversFoundSessionInDescendingOrder() async throws {
        let sut = makeSUT()
        let allID = [UUID(), UUID(), UUID()]
        let allSessions = allID.map { anySession(id: $0) }
        
        for session in allSessions {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSessions.sortedBySessionInDescendingOrder(), withQuery: .all(sort: .bySessionId(ascending: false)))
    }
    
    func test_retrieveSession_allSortedByDate_deliversFoundSessionsInAscendingOrder() async throws {
        let sut = makeSUT()
        let allDates = [Date().advanced(by: -200), Date().advanced(by: -100), Date()]
        let allSession = allDates.map { anySession(date: $0) }
        
        for session in allSession {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSession.sortedByDateInAscendingOrder(), withQuery: .all(sort: .byDate(ascending: true)))
    }
    
    func test_retrieveSession_allSortedByDateInReverse_deliversFoundSessionsInDescendingOrder() async throws {
        let sut = makeSUT()
        let allDates = [Date().advanced(by: -200), Date().advanced(by: -100), Date()]
        let allSession = allDates.map { anySession(date: $0) }
        
        for session in allSession {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSession.sortedByDateInDescendingOrder(), withQuery: .all(sort: .byDate(ascending: false)))
    }
    
    func test_retrieveSession_id_deliversCorrespondingSessionWithExactID() async throws {
        let sut = makeSUT()
        let id = UUID()
        let session = anySession(id: id)
        
        let allSession = [anySession(), session, anySession()]
        
        for session in allSession {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: [session], withQuery: .sessionID(id: id))
    }
    
    func test_insertSessionWithEntryAndSet_deliversFoundSessionWithPersistedEntryAndSet() async throws {
        let sut = makeSUT()
        let session = anySession(
            entries: [anyEntry(
                sets: [anySet()])])
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieveSession: [session])
    }
    
    func test_insertSessionWithSameID_wouldNotCreateNewSessionButOverwirteTheExistingOne() async throws {
        let sut = makeSUT()
        let id = UUID()
        let firstInsertionSession = anySession(id: id, entries: [anyEntry()])
        let sessionWithSameID = anySession(id: id, entries: [anyEntry()])
        
        try await sut.insert(firstInsertionSession)
        try await sut.insert(sessionWithSameID)
        
        try await expect(sut, toRetrieveSession: [sessionWithSameID])
    }
    
    func test_insert_toSameSession_wouldNotOverwriteExistingSessionAndItsEntries() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        let presavedEntryId = UUID()
        let session = anySession(id: sessionId, entries: [anyEntry(id: presavedEntryId)])
        let addedEntries = [anyEntry(), anyEntry()]
        
        try await sut.insert(session)
        try await sut.insert(addedEntries, to: session)
        try await expect(sut, toRetrieveEntriesWithIDs: [presavedEntryId] + addedEntries.map(\.id))
    }
    
    func test_insert_toNonExistantSession_createsSessionAndInsertsTheGivenEntries() async throws {
        let sut = makeSUT()
        let entry = anyEntry()
        let session = anySession()
        let expectedSession = appendingEntries([entry], to: session)
        
        try await sut.insert([entry], to: session)
        
        try await expect(sut, toRetrieveSession: [expectedSession])
    }
    
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
        
        do {
            try await sut.delete(anySession())
        } catch {
            XCTFail("Expected SUT to delete without any error on non existant session")
        }
        
        try await expect(sut, toRetrieveSession: [session])
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SwiftDataWorkoutSessionStore {
        let schema = Schema([WorkoutSession.self])
        let sut = try! SwiftDataWorkoutSessionStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveSession expected: [WorkoutSessionDTO], withQuery query: SessionQuery = .all(sort: nil), file: StaticString = #file, line: UInt = #line) async throws {
        
        let retrieved = try await sut.retrieveSession(query)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveSessionTwice expected: [WorkoutSessionDTO], withQuery query: SessionQuery = .all(sort: nil), file: StaticString = #file, line: UInt = #line) async throws {
        
        try await expect(sut, toRetrieveSession: expected, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieveSession: expected, withQuery: query, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntriesWithIDs ids: [UUID], withQuery query: SessionQuery = .all(sort: nil), file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieveSession(query).flatMap(\.entries)
        XCTAssertEqual(retrieved.map(\.id).sorted(), ids.sorted(), file: file, line: line)
    }
    
    private func anySession(id: UUID = UUID(), date: Date = .now, entries: [WorkoutEntryDTO] = []) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: id, date: date, entries: entries)
    }
    
    private func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSetDTO] = []) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exercise, sets: sets)
    }
    
    private func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0) -> WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight)
    }
    
    private func appendingEntries(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: session.id, date: session.date, entries: session.entries + entries)
    }
}

extension Array where Element == WorkoutSessionDTO {
    func sortedBySessionInAscendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.id < $1.id }
    }
    
    func sortedBySessionInDescendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.id > $1.id }
    }
    
    func sortedByDateInAscendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.date < $1.date }
    }
    
    func sortedByDateInDescendingOrder() -> [WorkoutSessionDTO] {
        sorted { $0.date > $1.date }
    }
}
