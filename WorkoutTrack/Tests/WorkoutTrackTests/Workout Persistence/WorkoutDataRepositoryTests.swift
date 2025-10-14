//
//  WorkoutDataManagerTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/8.
//

import XCTest
import SwiftData
@testable import WorkoutTrack

enum WorkoutQuery {
    case all
}

extension WorkoutQuery {
    var predicate: Predicate<WorkoutSession>? {
        switch self {
        case .all:
            return nil
        }
    }
}

@ModelActor
final actor SwiftDataWorkoutSessionStore {
    
    func retrieveSession(_ query: WorkoutQuery) throws -> [WorkoutSessionDTO] {
        var descriptor = FetchDescriptor<WorkoutSession>()
        if let predicate = query.predicate {
            descriptor.predicate = predicate
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
        
        try await expect(sut, toRetrieveSession: [session], withQuery: .all)
    }
    
    func test_retrieveSession_all_hasNoSideEffectOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let session = anySession()
        
        await sut.insert(session)
        
        try await expect(sut, toRetrieveSessionTwice: [session], withQuery: .all)
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
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveSession expected: [WorkoutSessionDTO], withQuery query: WorkoutQuery = .all, file: StaticString = #file, line: UInt = #line) async throws {
        
        let retrieved = try await sut.retrieveSession(query)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveSessionTwice expected: [WorkoutSessionDTO], withQuery query: WorkoutQuery = .all, file: StaticString = #file, line: UInt = #line) async throws {
        
        try await expect(sut, toRetrieveSession: expected, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieveSession: expected, withQuery: query, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataWorkoutSessionStore, toRetrieveEntriesWithIDs ids: [UUID], withQuery query: WorkoutQuery = .all, file: StaticString = #file, line: UInt = #line) async throws {
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
