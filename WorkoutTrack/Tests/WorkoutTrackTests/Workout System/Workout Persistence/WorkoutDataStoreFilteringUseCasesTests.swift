//
//  WorkoutDataStoreFilteringUseCasesTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//

import XCTest
@testable import WorkoutTrack

final class WorkoutDataStoreFilteringUseCasesTests: WorkoutDataStoreTests {
    
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
        let bExerciseEntryOne = anyEntry(exercise: exerciseB, createdAt: Date().adding(minutes: 1))
        let bExerciseEntryTwo = anyEntry(exercise: exerciseB, createdAt: Date().adding(minutes: 1))
        let otherEntry = anyEntry(createdAt: Date())

        let sessionWithAllSpecifiedExercise = anySession(entries: [bExerciseEntryOne, validEntryA, otherEntry])
        let session2 = anySession(entries: [bExerciseEntryTwo])

        let descriptor = QueryBuilder()
            .containsExercises([exerciseA, exerciseB])
            .sort(by: .byDate(ascending: true))
            .build()
        
        try await sut.insert(sessionWithAllSpecifiedExercise)
        try await sut.insert(session2)

        let expected = [
            anySession(
                id: sessionWithAllSpecifiedExercise.id,
                date: sessionWithAllSpecifiedExercise.date,
                entries: [bExerciseEntryOne, validEntryA, otherEntry].sortedByDefaultOrder()
            )
            ,
            anySession(
                id: session2.id,
                date: session2.date,
                entries: [bExerciseEntryTwo]
            )
        ]

        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
    }
    
    func test_retrieve_containsExercises_deliversNoEntriesWhenNoExerciseIsMatching() async throws {
        let sut = makeSUT()
        let anyExerciseID = UUID()
        let session = anySession(entries: [anyEntry(), anyEntry()])

        let descriptor = QueryBuilder()
            .containsExercises([anyExerciseID])
            .sort(by: .byId(ascending: true))
            .build()

        try await sut.insert(session)

        try await expect(sut, toRetrieve: [], withQuery: descriptor)
    }
    
    func test_retrieve_onlyIncludeFinishedSets_deliversSessionsWithFinishedSetsOnly() async throws {
        let sut = makeSUT()
        let validSets1 = [
            anySet(isFinished: true, order: 0),
            anySet(isFinished: true, order: 1),
            anySet(isFinished: true, order: 2)
        ]
        let validSets2 = [
            anySet(isFinished: true, order: 0),
            anySet(isFinished: true, order: 1)
        ]
        let sets1 = validSets1 + [anySet(isFinished: false), anySet(isFinished: false)]
        let sets2 = validSets2 + [anySet(isFinished: false)]
        let entry1 = anyEntry(sets: sets1, createdAt: Date().adding(seconds: -1))
        let entry2 = anyEntry(sets: sets2)
        let session = anySession(entries: [entry1, entry2])
        let descriptor = QueryBuilder()
            .onlyIncludFinishedSets()
            .build()
        
        try await sut.insert(session)
        
        let expectedEntries = [
            anyEntry(id: entry1.id, exercise: entry1.exerciseID, sets: validSets1.sortedByDefaultOrder(), createdAt: entry1.createdAt, order: entry1.order),
            anyEntry(id: entry2.id, exercise: entry2.exerciseID, sets: validSets2.sortedByDefaultOrder(), createdAt: entry2.createdAt, order: entry2.order)
        ]
        let expected = anySession(
            id: session.id,
            date: session.date,
            entries: expectedEntries
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
    
    func test_retrieve_filtersByDateRangeAndExercisesTogether() async throws {
        let sut = makeSUT()
        let exerciseA = UUID()
        let exerciseB = UUID()

        let validDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
        let insideRangeDate = validDate.adding(days: 1).adding(seconds: -1) // still within validDate...validDate
        let outsideBefore = validDate.adding(seconds: -1)

        let validEntryA = anyEntry(exercise: exerciseA, createdAt: Date().adding(seconds: -1))
        let validEntryB = anyEntry(exercise: exerciseB)
        let otherEntryForValidSession = anyEntry()

        // ✅ This session has both: valid date AND valid exercise → should be included
        let matchingSession = anySession(date: insideRangeDate, entries: [validEntryA, otherEntryForValidSession])
        
        // ❌ Valid date, but invalid exercises → should be excluded
        let sessionWithWrongExercise = anySession(date: insideRangeDate, entries: [anyEntry()])

        // ❌ Valid exercises, but outside date range → should be excluded
        let sessionWithWrongDate = anySession(date: outsideBefore, entries: [validEntryB])
        
        let descriptor = QueryBuilder()
            .filterDateRange(validDate...validDate)
            .containsExercises([exerciseA, exerciseB])
            .sort(by: .byDate(ascending: true))
            .build()

        try await sut.insert(matchingSession)
        try await sut.insert(sessionWithWrongExercise)
        try await sut.insert(sessionWithWrongDate)

        let expected = [
            anySession(
                id: matchingSession.id,
                date: matchingSession.date,
                entries: [validEntryA, otherEntryForValidSession].sortedByDefaultOrder()
            )
        ]

        try await expect(sut, toRetrieve: expected, withQuery: descriptor)
    }
    
    func test_retrieve_filterSetsReturnsAllSetsThatMatchTheIDs() async throws {
        let sut = makeSUT()
        let idA = UUID(),
            idB = UUID()
        let setA = anySet(id: idA, order: 0),
            setB = anySet(id: idB, order: 1),
            setC = anySet(order: 2)
        let descriptor = QueryBuilder()
            .filterSet([idA, idB])
            .build()
        
        try await sut.insert([anyEntry(sets: [setA, setB, setC])], to: anySession())
        
        try await expect(sut, toRetrieveSets: [setA, setB], withQuery: descriptor)
    }
}
