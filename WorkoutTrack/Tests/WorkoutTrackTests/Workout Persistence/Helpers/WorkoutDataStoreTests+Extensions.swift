//
//  SharedHelpers.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/2.
//

import XCTest
import SwiftData
@testable import WorkoutTrack

class WorkoutDataStoreTests: XCTestCase {}

extension WorkoutDataStoreTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> WorkoutSessionStore {
        let schema = Schema([WorkoutSession.self])
        let sut = try! SwiftDataWorkoutSessionStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func anySession(id: UUID = UUID(), date: Date = .now, entries: [WorkoutEntryDTO] = []) -> WorkoutSessionDTO {
        WorkoutSessionDTO(id: id, date: date, entries: entries)
    }
    
    func anyEntry(id: UUID = UUID(), exercise: UUID = UUID(), sets: [WorkoutSetDTO] = [], createdAt: Date = Date(), order: Int = 0) -> WorkoutEntryDTO {
        WorkoutEntryDTO(id: id, exerciseID: exercise, sets: sets, createdAt: createdAt, order: order)
    }
    
    func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0.0, isFinished: Bool = false, order: Int = 0) -> WorkoutSetDTO {
        WorkoutSetDTO(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
    }
    
    func expect(_ sut: WorkoutSessionStore, toRetrieveEntry expected: [WorkoutEntryDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        
        let retrieved = try await sut.retrieve(query: query).flatMap(\.entries)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    func expect(_ sut: WorkoutSessionStore, toRetrieveEntryTwice expected: [WorkoutEntryDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        
        try await expect(sut, toRetrieveEntry: expected, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieveEntry: expected, withQuery: query, file: file, line: line)
    }
    
    func expect(_ sut: WorkoutSessionStore, toRetrieveEntriesWithIDs ids: [UUID], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieve(query: query).flatMap(\.entries)
        XCTAssertEqual(retrieved.map(\.id), ids.sorted(), file: file, line: line)
    }
    
    func expect(_ sut: WorkoutSessionStore, toRetrieve expectedSessions: [WorkoutSessionDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieve = try await sut.retrieve(query: query)
        XCTAssertEqual(retrieve, expectedSessions, file: file, line: line)
    }
    
    func expect(_ sut: WorkoutSessionStore, toRetrieveTwice expectedSessions: [WorkoutSessionDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        try await expect(sut, toRetrieve: expectedSessions, withQuery: query, file: file, line: line)
        try await expect(sut, toRetrieve: expectedSessions, withQuery: query, file: file, line: line)
    }
    
    func expect(_ sut: WorkoutSessionStore, toRetrieveSets expectedSets: [WorkoutSetDTO], withQuery query: SessionQueryDescriptor? = nil, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieve(query: query).flatMap(\.entries).flatMap(\.sets)
        XCTAssertEqual(retrieved, expectedSets, file: file, line: line)
    }
}
