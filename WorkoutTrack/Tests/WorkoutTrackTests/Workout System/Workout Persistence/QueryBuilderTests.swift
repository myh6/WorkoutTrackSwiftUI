//
//  QueryBuilderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/19.
//

@testable import WorkoutTrack
import XCTest

final class QueryBuilderTests: XCTestCase {
    
    func test_build_createsDescriptorWithNoProperties() {
        let descriptor = QueryBuilder()
            .build()
        
        XCTassertQueryDescriptorEmpty(descriptor: descriptor)
    }
    
    func test_build_withDateRange_createsDescriptorWithCorrectRange() {
        let from = Date().adding(days: -1)
        let to = Date()
        
        let descriptor = QueryBuilder()
            .filterDateRange(from...to)
            .build()
        
        XCTAssertDescriptionOnlyHas(\.dateRange, equalTo: (from...to), in: descriptor)
    }
    
    func test_build_withSortBy_createsDescriptorWithCorrectDateSort() {
        let descriptor = QueryBuilder()
            .sort(by: .byDate(ascending: true))
            .sort(by: .byId(ascending: false))
            .build()
        
        XCTAssertDescriptionOnlyHas(\.sortBy, equalTo: [
            .byDate(ascending: true),
            .byId(ascending: false)
        ], in: descriptor)
    }
    
    func test_build_filterSession_createsDescriptorWithCorrectFIlter() {
        let targetId = UUID()
        let descriptor = QueryBuilder()
            .filterSession(targetId)
            .build()
        
        XCTAssertDescriptionOnlyHas(\.sessionId, equalTo: targetId, in: descriptor)
    }
    
    func test_build_postProcessing_createsDescriptorWithCorrectPostProcessing() {
        let ids = [UUID(), UUID(), UUID()]
        let containIDs = [UUID(), UUID(), UUID()]
        
        let descriptor = QueryBuilder()
            .sort(by: .entryCustomOrder)
            .containsExercises(containIDs)
            .onlyIncludFinishedSets()
            .onlyIncludExercises(ids)
            .build()
        
        XCTAssertDescriptionOnlyHas(\.postProcessing, equalTo: [
            .sortByEntryCustomOrder,
            .containsExercises(containIDs),
            .onlyIncludFinishedSets,
            .onlyIncludeExercises(ids),
        ], in: descriptor)
    }
    
    //MARK: - Helpers
    private func XCTassertQueryDescriptorEmpty(descriptor: SessionQueryDescriptor, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(descriptor.sessionId, file: file, line: line)
        XCTAssertNil(descriptor.dateRange, file: file, line: line)
        XCTAssertNil(descriptor.containExercises, file: file, line: line)
        XCTAssertNil(descriptor.sortBy, file: file, line: line)
        XCTAssertNil(descriptor.postProcessing, file: file, line: line)
    }
    
    private func XCTAssertDescriptionOnlyHas<T: Equatable>(
        _ keyPath: KeyPath<SessionQueryDescriptor, T?>,
        equalTo expected: T?,
        in descriptor: SessionQueryDescriptor,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertEqual(descriptor[keyPath: keyPath], expected, file: file, line: line)
        
        if keyPath != \SessionQueryDescriptor.dateRange {
            XCTAssertNil(descriptor.dateRange, file: file, line: line)
        }
        
        if keyPath != \SessionQueryDescriptor.sortBy {
            XCTAssertNil(descriptor.sortBy, file: file, line: line)
        }
        
        if keyPath != \SessionQueryDescriptor.containExercises {
            XCTAssertNil(descriptor.containExercises, file: file, line: line)
        }
        
        if keyPath != \SessionQueryDescriptor.postProcessing {
            XCTAssertNil(descriptor.postProcessing, file: file, line: line)
        }
        
        if keyPath != \SessionQueryDescriptor.sessionId {
            XCTAssertNil(descriptor.sessionId, file: file, line: line)
        }
    }
}

extension Date {
    func adding(seconds: TimeInterval, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
