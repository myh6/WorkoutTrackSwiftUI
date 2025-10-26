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

        let entry1 = anyEntry(createdAt: Date().advanced(by: -100))
        let entry2 = anyEntry(createdAt: Date().advanced(by: -300))
        let entry3 = anyEntry(createdAt: Date())

        let session = anySession(entries: [entry1, entry2, entry3].shuffled())
        try await sut.insert(session)

        let expected = [
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: [entry2, entry1, entry3]
            )
        ]

        try await expect(sut, toRetrieve: expected)
    }
    
    func test_retrieve_entryCustomOrder_deliversEntryInCustomOrder() async throws {
        let sut = makeSUT()
        
        let entry4 = anyEntry(order: 4)
        let entry1 = anyEntry(order: 1)
        let entry2 = anyEntry(order: 2)
        let entry5 = anyEntry(order: 5)
        let entry3 = anyEntry(order: 3)
        
        let session = anySession(entries: [entry4, entry1, entry2, entry5, entry3].shuffled())
        
        let descriptor = QueryBuilder()
            .sort(by: .entryCustomOrder)
            .build()
        
        try await sut.insert(session)
        
        let expected = [
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: [entry1, entry2, entry3, entry4, entry5]
            )
        ]
        
        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
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
        
    func test_retrieve_containsExercises_filtersOutSessionsWithoutAnyMatchingExercise() async throws {
        let sut = makeSUT()
        let exerciseA = UUID()
        let exerciseB = UUID()

        let validEntryA = anyEntry(exercise: exerciseA, createdAt: Date().adding(seconds: -2))
        let otherEntry = anyEntry(createdAt: Date().adding(seconds: 1))
        let sessionWithOneSpecifiedExercise = anySession(entries: [validEntryA, otherEntry])

        let invalidSession = anySession(entries: [anyEntry()])

        let descriptor = QueryBuilder()
            .containsExercises([exerciseA, exerciseB])
            .sort(by: .byId(ascending: true))
            .build()

        try await sut.insert(sessionWithOneSpecifiedExercise)
        try await sut.insert(invalidSession)

        let expected = [
            anySession(
                id: sessionWithOneSpecifiedExercise.id,
                date: sessionWithOneSpecifiedExercise.date,
                entries: [validEntryA, otherEntry]
            )
        ]

        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
    }

    func test_retrieve_containsExercises_retainsSessionsWithAnyMatchingExercise() async throws {
        let sut = makeSUT()
        let exerciseA = UUID()
        let exerciseB = UUID()

        let validEntryA = anyEntry(exercise: exerciseA, createdAt: Date().adding(minutes: 2))
        let validEntryB = anyEntry(exercise: exerciseB, createdAt: Date().adding(minutes: 1))
        let otherEntry = anyEntry(createdAt: Date())

        let sessionWithAllSpecifiedExercise = anySession(entries: [validEntryB, validEntryA, otherEntry])

        let descriptor = QueryBuilder()
            .containsExercises([exerciseA, exerciseB])
            .sort(by: .byId(ascending: true))
            .build()

        try await sut.insert(sessionWithAllSpecifiedExercise)

        let expected = [
            anySession(
                id: sessionWithAllSpecifiedExercise.id,
                date: sessionWithAllSpecifiedExercise.date,
                entries: [validEntryB, validEntryA, otherEntry].sortedByDefaultOrder()
            )
        ]

        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
    }
    
    func test_retrieve_onlyIncludeFinishedSets_deliversSessionsWithFinishedSetsOnly() async throws {
        let sut = makeSUT()
        let validSets = [
            anySet(isFinished: true, order: 2),
            anySet(isFinished: true, order: 1),
            anySet(isFinished: true, order: 4)
        ]
        let sets = validSets + [anySet(isFinished: false, order: 0), anySet(isFinished: false, order: 3)]
        let entry = anyEntry(sets: sets.shuffled())
        let session = anySession(entries: [entry])
        let descriptor = QueryBuilder()
            .onlyIncludFinishedSets()
            .build()
        
        try await sut.insert(session)
        
        let expected = anySession(
            id: session.id,
            date: session.date,
            entries: [
                anyEntry(
                    id: entry.id,
                    exercise: entry.exerciseID,
                    sets: validSets.sortedByDefaultOrder(),
                    createdAt: entry.createdAt,
                    order: entry.order
                )
            ]
        )
        
        try await expect(sut, toRetrieve: [expected], withQuery: descriptor)
    }
    
    func test_retrieve_onlyIncludeExercises_filtersOutNonIncludedEntriesWithinSessions() async throws {
        let sut = makeSUT()
        let exerciseA = UUID(), exerciseB = UUID()
        let validEntry = [anyEntry(exercise: exerciseA, createdAt: Date().adding(seconds: -1)), anyEntry(exercise: exerciseB)]
        let session1 = anySession(entries: (validEntry + [anyEntry(), anyEntry()]).shuffled())
        let sessions = [
            session1, anySession(entries: [anyEntry()])
        ]
        let descriptor = QueryBuilder()
            .onlyIncludExercises([exerciseA, exerciseB])
            .build()
        
        for session in sessions {
            try await sut.insert(session)
        }
        
        let expected = [
            anySession(
                id: session1.id,
                date: session1.date,
                entries: validEntry.sortedByDefaultOrder()
            )
        ]
        
        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
    }
    
    func test_retrieve_onlyIncludeExercises_retainsSessionsWithAnyMatchingExercise() async throws {
        let sut = makeSUT()
        let exerciseA = UUID(), exerciseB = UUID()
        let validEntry = [anyEntry(exercise: exerciseA)]
        let session1 = anySession(entries: (validEntry + [anyEntry(), anyEntry()]).shuffled())
        let sessions = [
            session1, anySession(entries: [anyEntry()])
        ]
        let descriptor = QueryBuilder()
            .onlyIncludExercises([exerciseA, exerciseB])
            .build()
        
        for session in sessions {
            try await sut.insert(session)
        }
        
        let expected = [
            anySession(
                id: session1.id,
                date: session1.date,
                entries: validEntry.sortedByDefaultOrder()
            )
        ]
        
        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
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
    
    // TODO: - Insert multiple sets using sesson insertion might have wrong order property.
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
        XCTAssertEqual(retrieved.map(\.id), ids.sorted(), file: file, line: line)
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
    
    private func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0, isFinished: Bool = false, order: Int = 0) -> WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
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

extension Array where Element == WorkoutEntryDTO {
    func sortedByDefaultOrder() -> [WorkoutEntryDTO] {
        return sortedByEntryCreatedAtInAscendingOrder()
    }
    
    func sortedByEntryCreatedAtInAscendingOrder() -> [WorkoutEntryDTO] {
        sorted { $0.createdAt < $1.createdAt }
    }
}

extension Array where Element == WorkoutSetDTO {
    func sortedByDefaultOrder() -> [WorkoutSetDTO] {
        sortedByOrder()
    }
    
    func sortedByOrder() -> [WorkoutSetDTO] {
        sorted { $0.order < $1.order }
    }
}
