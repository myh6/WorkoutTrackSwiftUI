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
