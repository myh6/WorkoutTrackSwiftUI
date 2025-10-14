//
//  WorkoutDataManagerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import XCTest
import SwiftData
@testable import WorkoutTrack

enum SessionQuery {
    case all(sort: SessionSort?)
}

enum SessionSort {
    case bySessionId(ascending: Bool)
    case byDate(ascending: Bool)
}

extension SessionQuery {
    var predicate: Predicate<WorkoutSession>? {
        switch self {
        case .all:
            return nil
        }
    }
    
    var sort: SessionSort? {
        switch self {
        case .all(let sort):
            return sort
        }
    }
    
    var sortDescriptor: SortDescriptor<WorkoutSession>? {
        switch self.sort {
        case .bySessionId(let ascending):
            return SortDescriptor(\.id, order: ascending ? .forward : .reverse)
        case .byDate(let ascending):
            return SortDescriptor(\.date, order: ascending ? .forward : .reverse)
        case .none:
            return nil
        }
    }
}

@ModelActor
final actor SwiftDataWorkoutSessionStore {
    
    func retrieveSession(_ query: SessionQuery) throws -> [WorkoutSessionDTO] {
        var descriptor = FetchDescriptor<WorkoutSession>()
        if let predicate = query.predicate {
            descriptor.predicate = predicate
        }
        if let sort = query.sortDescriptor {
            descriptor.sortBy = [sort]
        }
        return try modelContext.fetch(descriptor).map(\.dto)
    }
    
    func insert(_ session: WorkoutSessionDTO) {
        let model = WorkoutSession(dto: session)
        modelContext.insert(model)
    }
    
    func insert(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) throws {
        let targetID = session.id
        let descriptor = FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.id == targetID })
        if let session = try modelContext.fetch(descriptor).first {
            entries.map{ WorkoutEntry(dto: $0) }.forEach {
                $0.session = session
                modelContext.insert($0)
                session.entries.append($0)
            }
        }
        try modelContext.save()
    }
}

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
        
        await sut.insert(session)
        
        try await expect(sut, toRetrieveSession: [session], withQuery: .all(sort: nil))
    }
    
    func test_retrieveSession_hasNoSideEffectOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let session = anySession()
        
        await sut.insert(session)
        
        try await expect(sut, toRetrieveSessionTwice: [session])
    }
    
    func test_retrieveSession_allSortedBySessionID_deliversFoundSessionInSortedOrder() async throws {
        let sut = makeSUT()
        let allID = [UUID(), UUID(), UUID()]
        let allSessions = allID.map { anySession(id: $0) }
        
        for session in allSessions {
            await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSessions.sortedBySessionInAscendingOrder(), withQuery: .all(sort: .bySessionId(ascending: true)))
    }
    
    func test_retrieveSession_allSortedBySessionIdInReverse_deliversFoundSessionInDescendingOrder() async throws {
        let sut = makeSUT()
        let allID = [UUID(), UUID(), UUID()]
        let allSessions = allID.map { anySession(id: $0) }
        
        for session in allSessions {
            await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSessions.sortedBySessionInDescendingOrder(), withQuery: .all(sort: .bySessionId(ascending: false)))
    }
    
    func test_retrieveSession_allSortedByDate_deliversFoundSessionsInAscendingOrder() async throws {
        let sut = makeSUT()
        let allDates = [Date().advanced(by: -200), Date().advanced(by: -100), Date()]
        let allSession = allDates.map { anySession(date: $0) }
        
        for session in allSession {
            await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSession.sortedByDateInAscendingOrder(), withQuery: .all(sort: .byDate(ascending: true)))
    }
    
    func test_retrieveSession_allSortedByDateInReverse_deliversFoundSessionsInDescendingOrder() async throws {
        let sut = makeSUT()
        let allDates = [Date().advanced(by: -200), Date().advanced(by: -100), Date()]
        let allSession = allDates.map { anySession(date: $0) }
        
        for session in allSession {
            await sut.insert(session)
        }
        
        try await expect(sut, toRetrieveSession: allSession.sortedByDateInDescendingOrder(), withQuery: .all(sort: .byDate(ascending: false)))
    }
    
    func test_insertSessionWithEntryAndSet_deliversFoundSessionWithPersistedEntryAndSet() async throws {
        let sut = makeSUT()
        let session = anySession(
            entries: [anyEntry(
                sets: [anySet()])])
        
        await sut.insert(session)
        
        try await expect(sut, toRetrieveSession: [session])
    }
    
    func test_insert_toSameSession_wouldNotOverwriteExistingSessionAndItsEntries() async throws {
        let sut = makeSUT()
        let sessionId = UUID()
        let presavedEntryId = UUID()
        let session = anySession(id: sessionId, entries: [anyEntry(id: presavedEntryId)])
        let addedEntries = [anyEntry(), anyEntry()]
        
        await sut.insert(session)
        try await sut.insert(addedEntries, to: session)
        try await expect(sut, toRetrieveEntriesWithIDs: [presavedEntryId] + addedEntries.map(\.id))
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
