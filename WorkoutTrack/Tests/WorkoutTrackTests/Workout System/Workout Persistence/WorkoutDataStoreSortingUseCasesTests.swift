//
//  WorkoutDataStoreSortingUseCasesTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//


import XCTest
@testable import WorkoutTrack

final class WorkoutDataStoreSortingUseCasesTests: WorkoutDataStoreTests {
    
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
    
    func test_retrieve_entriesDefaultWithSameCreatedAt_areSortedByCustomOrderThenByUUID() async throws {
        let sut = makeSUT()
        let sameTime = Date()
        let entry1 = anyEntry(createdAt: sameTime, order: 0)
        let entry2 = anyEntry(createdAt: sameTime, order: 0)
        let entry3 = anyEntry(createdAt: sameTime, order: 2)
        let entry4 = anyEntry(createdAt: sameTime, order: 3)
        
        let session = anySession(entries: [entry1, entry2, entry3, entry4].shuffled())
        try await sut.insert(session)
        
        let expected = [
            WorkoutSessionDTO(
                id: session.id,
                date: session.date,
                entries: [entry1, entry2].sorted{ $0.id < $1.id} + [entry3, entry4])
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
    
}
