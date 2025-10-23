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
    
    func test_retrieve_sortedBySessionIdInReverse_deliversFoundSessionsInDescendingOrder() async throws {
        let sut = makeSUT()
        let allSessions = [anySession(), anySession(), anySession()]
        let descriptor = QueryBuilder()
            .sort(by: .byId(ascending: false))
            .build()
        
        for session in allSessions {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieve: allSessions.sortedBySessionInDescendingOrder(), withQuery: descriptor)
    }
    
    func test_retrieve_sortedByDate_deliversFoundSessionsInAscendingOrder() async throws {
        let sut = makeSUT()
        let allSession = [Date().advanced(by: -100), Date().advanced(by: -300), Date()]
            .map { anySession(date: $0) }
        let descriptor = QueryBuilder()
            .sort(by: .byDate(ascending: true))
            .build()
        
        for session in allSession {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieve: allSession.sortedByDateInAscendingOrder(), withQuery: descriptor)
    }
    
    func test_retrieve_sortedByDateInReverse_deliversFoundSessionsInDescendingOrder() async throws {
        let sut = makeSUT()
        let allSession = [Date().advanced(by: -200), Date().advanced(by: -100), Date()]
            .map { anySession(date: $0) }
        let descriptor = QueryBuilder()
            .sort(by: .byDate(ascending: false))
            .build()
        
        for session in allSession {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieve: allSession.sortedByDateInDescendingOrder(), withQuery: descriptor)
    }
    
    func test_retrieve_entryDefault_deliversEntryInCreatedAtAscendingOrder() async throws {
        let sut = makeSUT()
        let allEntry = [Date().advanced(by: -100), Date().advanced(by: -300), Date()].map { anyEntry(createdAt: $0) }
        let session = anySession(entries: allEntry)
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieve: [session].sortedByEntryCreatedAtInAscendingOrder())
    }
    
    func test_retrieve_id_deliversCorrespondingSessionWithExactID() async throws {
        let sut = makeSUT()
        let id = UUID()
        let session = anySession(id: id)
        let allSession = [anySession(), session, anySession()]
        let descriptor = QueryBuilder()
            .filterSession(id)
            .build()
        
        for session in allSession {
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieve: [session], withQuery: descriptor)
    }
    
    func test_retrieve_dateRange_deliversSessionsThatFallWithinTheSpecifiedDateRange() async throws {
        let sut = makeSUT()
        let validDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
        let validSession = anySession(date: validDate.adding(days: 1).adding(seconds: -1))
        let oneSecondLess = anySession(date: validDate.adding(seconds: -1))
        let oneDayLater = anySession(date: validDate.adding(days: 1))
        
        let descriptor = QueryBuilder()
            .filterDateRange(validDate...validDate)
            .build()
        
        for session in [validSession, oneSecondLess, oneDayLater] {
            print(session.date)
            try await sut.insert(session)
        }
        
        try await expect(sut, toRetrieve: [validSession], withQuery: descriptor)
    }
    
    
    // TODO: - Add sorting to this test for entries
    func test_retrieve_exercises_deliversSessionsWithOneOfTheSpecifiedExercise() async throws {
        let sut = makeSUT()
        let exerciseA = UUID()
        let exerciseB = UUID()
        let sessionWithOneSpecifiedExercise = anySession(entries: [anyEntry(exercise: exerciseA)])
        let sessionWithAnotherSpecifiedExercise = anySession(entries: [anyEntry(exercise: exerciseB)])
        let sessionWithDifferentExercise = anySession(entries: [anyEntry()])
        let descriptor = QueryBuilder()
            .containsExercises([exerciseA, exerciseB])
            .sort(by: .byId(ascending: true))
            .build()
        
        try await sut.insert(sessionWithOneSpecifiedExercise)
        try await sut.insert(sessionWithAnotherSpecifiedExercise)
        try await sut.insert(sessionWithDifferentExercise)
        
        try await expect(sut, toRetrieve: [sessionWithOneSpecifiedExercise, sessionWithAnotherSpecifiedExercise].sortedBySessionInAscendingOrder(), withQuery: descriptor)
    }
    
    func test_insertWithEntryAndSet_deliversFoundSessionWithPersistedEntryAndSet() async throws {
        let sut = makeSUT()
        let session = anySession(
            entries: [anyEntry(
                sets: [anySet()])])
        
        try await sut.insert(session)
        
        try await expect(sut, toRetrieve: [session])
    }
    
    func test_insertSessionWithSameID_wouldNotCreateNewSessionButOverwirteTheExistingOne() async throws {
        let sut = makeSUT()
        let id = UUID()
        let firstInsertionSession = anySession(id: id, entries: [anyEntry()])
        let sessionWithSameID = anySession(id: id, entries: [anyEntry()])
        
        try await sut.insert(firstInsertionSession)
        try await sut.insert(sessionWithSameID)
        
        try await expect(sut, toRetrieve: [sessionWithSameID])
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
        
        try await expect(sut, toRetrieve: [expectedSession])
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
        
        try await expect(sut, toRetrieve: [session])
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
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SwiftDataWorkoutSessionStore {
        let schema = Schema([WorkoutSession.self])
        let sut = try! SwiftDataWorkoutSessionStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntry expected: [WorkoutEntryDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        
        let retrieved = try await sut.retrieve(query: query).flatMap(\.entries)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntryTwice expected: [WorkoutEntryDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        
        try await expect(sut, toRetrieveEntry: expected, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieveEntry: expected, withQuery: query, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntriesWithIDs ids: [UUID], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieve(query: query).flatMap(\.entries)
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
    
    private func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSetDTO] = [], createdAt: Date = Date(), order: Int = 0) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exercise, sets: sets, createdAt: createdAt, order: order)
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
    
    func sortedByEntryCreatedAtInAscendingOrder() -> [WorkoutSessionDTO] {
        map { session in
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: session.entries.sortedByEntryCreatedAtInAscendingOrder())
        }
    }
}

extension Array where Element == WorkoutEntryDTO {
    func sortedByIDInAscendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.id < $1.id }
    }
    
    func sortedByIDInDescendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.id > $1.id }
    }
    
    func sortedByEntryCreatedAtInAscendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.createdAt < $1.createdAt }
    }
}
