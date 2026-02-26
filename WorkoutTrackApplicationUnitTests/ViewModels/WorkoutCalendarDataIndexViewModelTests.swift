//
//  WorkoutCalendarDataIndexViewModelTests.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/2/24.
//

import Testing
import Foundation
import WorkoutTrack
@testable import WorkoutTrackSwiftUI

class WorkoutCalendarDataIndexViewModelTests {
    
    @Test
    func hasData_returnsFalse_beforePrefetch() {
        let (sut, _, _) = makeSUT()
        #expect(sut.hasData(Date()) == false)
    }
    
    @Test
    func prefetch_requestsSessionsFilteredByRange() async {
        let (sut, spy, calendar) = makeSUT()
        
        let start = date(calendar, year: 2026, month: 2, day: 1)
        let end = date(calendar, year: 2026, month: 2, day: 7)
        let range = start...end
        await sut.prefetch(in: range)
        
        let receivedQueryRange = retrieveRange(from: spy.receivedQuery.first)
        #expect(receivedQueryRange == range)
    }
    
    @Test
    func prefetch_marksReturnedSessionDatesAsHavingData() async {
        let (sut, spy, calendar) = makeSUT()
        
        let date1 = date(calendar, year: 2025, month: 12, day: 25)
        let date2 = date(calendar, year: 2026, month: 2, day: 25)
        
        spy.enqueueSession([
            [anySession(date: date1), anySession(date: date2)]
        ])
        
        await sut.prefetch(in: date1...date2)
        
        #expect(sut.hasData(date1))
        #expect(sut.hasData(date2))
        #expect(sut.hasData(date(calendar, year: 2026, month: 1, day:1)) == false)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (sut: WorkoutCalendarDataIndexViewModel, spy: WorkoutServiceSpy, calendar: Calendar) {
        let spy = WorkoutServiceSpy()
        let calendar = makeCalendar()
        let sut = WorkoutCalendarDataIndexViewModel(service: spy, calendar: calendar)
        return (sut, spy, calendar)
    }
    
    private func retrieveRange(from query: SessionQueryDescriptor?) -> ClosedRange<Date>? {
        guard let query else { return nil }
        return query.dateRange
    }
}

