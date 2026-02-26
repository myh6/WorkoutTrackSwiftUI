//
//  WorkoutCalendarDataIndexViewModelTests.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/2/24.
//

final class WorkoutCalendarDataIndexViewModel {
    private let service: WorkoutDayServicing
    
    init(service: WorkoutDayServicing) {
        self.service = service
    }
    
    func hasData(_ date: Date) -> Bool {
        return false
    }
    
    func prefetch(in range: ClosedRange<Date>) async {
        let query = QueryBuilder()
            .filterDateRange(range)
            .build()
        _ = try? await service.retrieveSessions(by: query)
    }
}

import Testing
import Foundation
import WorkoutTrack
@testable import WorkoutTrackSwiftUI

class WorkoutCalendarDataIndexViewModelTests {
    
    @Test
    func hasData_returnsFalse_beforePrefetch() {
        let (sut, _) = makeSUT()
        #expect(sut.hasData(Date()) == false)
    }
    
    @Test
    func prefetch_requestsSessionsFilteredByRange() async {
        let (sut, spy) = makeSUT()
        
        let start = date(year: 2026, month: 2, day: 1)
        let end = date(year: 2026, month: 2, day: 7)
        let range = start...end
        await sut.prefetch(in: range)
        
        let receivedQueryRange = retrieveRange(from: spy.receivedQuery.first)
        #expect(receivedQueryRange == range)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (sut: WorkoutCalendarDataIndexViewModel, spy: WorkoutServiceSpy) {
        let spy = WorkoutServiceSpy()
        let sut = WorkoutCalendarDataIndexViewModel(service: spy)
        return (sut, spy)
    }
    
    private func retrieveRange(from query: SessionQueryDescriptor?) -> ClosedRange<Date>? {
        guard let query else { return nil }
        return query.dateRange
    }
}

