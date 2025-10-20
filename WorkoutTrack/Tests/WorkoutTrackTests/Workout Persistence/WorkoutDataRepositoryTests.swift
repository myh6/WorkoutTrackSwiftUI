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
    
    func test_retrieve_sortedBySessionID_deliversFoundSessionInSortedOrder() async throws {
        let sut = makeSUT()
        let allSessions = [anySession(), anySession(), anySession()]
        let descriptor = QueryBuilder()
            .sort(by: .byId(ascending: true))
            .build()
        
        for session in allSessions {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieve: allSessions.sortedBySessionInAscendingOrder(), withQuery: descriptor)
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
    
    func test_deleteSession_deletesTheSpecificedSessionAndItsEntry() async throws {
        let sut = makeSUT()
        let session = anySession(entries: [anyEntry(), anyEntry(), anyEntry()])
        
        try await sut.insert(session)
        try await sut.delete(session)
        
        try await expect(sut, toRetrieveEntry: [])
    }
    
    func test_retrieveEntry_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveEntry: [])
    }
    
    func test_retrieveEntry_hasNoSideEffectOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveEntryTwice: [])
    }
    
    func test_retrieveEntry_allSortedById_deliversAllEntryFromDatabaseInAscendingOrder() async throws {
        let sut = makeSUT()
        let entryA = [anyEntry()]
        let sessionA = anySession(entries: entryA)
        let entryB = [anyEntry(), anyEntry(), anyEntry()]
        let sessionB = anySession(entries: entryB)
        
        try await sut.insert(sessionA)
        try await sut.insert(sessionB)
        
        try await expect(sut, toRetrieveEntry: (entryA + entryB).sortedByIDInAscendingOrder(), withQuery: .all(sort: .byId(ascending: true)))
    }
    
    func test_retrieveEntry_allSortedById_deliversAllEntryFromDatabaseInDescendingOrder() async throws {
        let sut = makeSUT()
        let entryA = [anyEntry()]
        let sessionA = anySession(entries: entryA)
        let entryB = [anyEntry(), anyEntry(), anyEntry()]
        let sessionB = anySession(entries: entryB)
        
        try await sut.insert(sessionA)
        try await sut.insert(sessionB)
        
        try await expect(sut, toRetrieveEntry: (entryA + entryB).sortedByIDInDescendingOrder(), withQuery: .all(sort: .byId(ascending: false)))
    }
    
    func test_retrieveEntry_allSortredByDate_deliversAllEntryFromDatabaseInAscendingOrder() async throws {
        let sut = makeSUT()
        let sessionA = anySession(date: Date(), entries: [anyEntry()])
        let sessionB = anySession(date: Date().advanced(by: -200), entries: [anyEntry()])
        let expectedEntries = [sessionA, sessionB].sortedByDateInAscendingOrderToEntries()
        
        try await sut.insert(sessionA)
        try await sut.insert(sessionB)
        
        try await expect(sut, toRetrieveEntry: expectedEntries, withQuery: .all(sort: .byDate(ascending: true)))
    }
    
    func test_retrieveEntry_allSortredByDate_deliversAllEntryFromDatabaseInDescendingOrder() async throws {
        let sut = makeSUT()
        let sessionA = anySession(date: Date(), entries: [anyEntry()])
        let sessionB = anySession(date: Date().advanced(by: -200), entries: [anyEntry()])
        let expectedEntries = [sessionA, sessionB].sortedByDateInDescendingOrderToEntries()
        
        try await sut.insert(sessionA)
        try await sut.insert(sessionB)
        
        try await expect(sut, toRetrieveEntry: expectedEntries, withQuery: .all(sort: .byDate(ascending: false)))
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
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntry expected: [WorkoutEntryDTO], withQuery query: EntryQuery = .all(sort: nil), file: StaticString = #file, line: UInt = #line) async throws {
        
        let retrieved = try await sut.retrieveEntry(query)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntryTwice expected: [WorkoutEntryDTO], withQuery query: EntryQuery = .all(sort: nil), file: StaticString = #file, line: UInt = #line) async throws {
        
        try await expect(sut, toRetrieveEntry: expected, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieveEntry: expected, withQuery: query, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntriesWithIDs ids: [UUID], withQuery query: SessionQuery = .all(sort: nil), file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieveSession(query).flatMap(\.entries)
        XCTAssertEqual(retrieved.map(\.id).sorted(), ids.sorted(), file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieve expectedSessions: [WorkoutSessionDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieve = try await sut.retrieve(query: query)
        XCTAssertEqual(retrieve, expectedSessions, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveTwice expectedSessions: [WorkoutSessionDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        try await expect(sut, toRetrieve: expectedSessions, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieve: expectedSessions, withQuery: query, file: file, line: line)
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
    
    func sortedByDateInAscendingOrderToEntries() -> [WorkoutEntryDTO] {
        sortedByDateInAscendingOrder().flatMap(\.entries)
    }
    
    func sortedByDateInDescendingOrderToEntries() -> [WorkoutEntryDTO] {
        sortedByDateInDescendingOrder().flatMap(\.entries)
    }
}

extension Array where Element == WorkoutEntryDTO {
    func sortedByIDInAscendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.id < $1.id }
    }
    
    func sortedByIDInDescendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.id > $1.id }
    }
}
