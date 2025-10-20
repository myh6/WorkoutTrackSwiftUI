//
//  QueryBuilderTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/19.
//

import WorkoutTrack
import XCTest

final class QueryBuilderTests: XCTestCase {
    
    func test_build_createsDescriptorWithNoProperties() {
        let descriptor = QueryBuilder()
            .build()
        
        XCTAssertNil(descriptor.dateRange)
        XCTAssertNil(descriptor.sortBy)
    }
    
    func test_build_withDateRange_createsDescriptorWithCorrectRange() {
        let from = Date().adding(days: -1)
        let to = Date()
        
        let descriptor = QueryBuilder()
            .filterDateRange(from...to)
            .build()
        
        XCTAssertEqual(descriptor.dateRange, from...to)
    }
    
    func test_build_withSortBy_createsDescriptorWithCorrectDateSort() {
        let descriptor = QueryBuilder()
            .sort(by: .byDate(ascending: true))
            .sort(by: .byId(ascending: false))
            .build()
        
        XCTAssertEqual(descriptor.sortBy, [.byDate(ascending: true), .byId(ascending: false)])
    }
    
    func test_build_containExercises_createsDescriptorWithCorrectFIlter() {
        let exercisesID = [UUID(), UUID(), UUID(), UUID()]
        let descriptor = QueryBuilder()
            .containsExercises(exercisesID)
            .build()
        
        XCTAssertEqual(descriptor.containExercises, exercisesID)
    }
    
    func test_build_filterSession_createsDescriptorWithCorrectFIlter() {
        let targetId = UUID()
        let descriptor = QueryBuilder()
            .filterSession(targetId)
            .build()
        
        XCTAssertEqual(descriptor.sessionId, targetId)
    }
    
    func test_build_postProcessing_createsDescriptorWithCorrectPostProcessing() {
        let ids = [UUID(), UUID(), UUID()]
        
        let descriptor = QueryBuilder()
            .onlyIncludFinishedSets()
            .onlyIncludExercises(ids)
            .limitToFirst(3)
            .build()
        
        XCTAssertEqual(descriptor.postProcessing, [
            .onlyIncludFinishedSets,
            .onlyIncludeExercises(ids),
            .limitToFirst(3)
        ])
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
