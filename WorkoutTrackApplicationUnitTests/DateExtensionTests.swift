//
//  WorkoutTrackApplicationUnitTests.swift
//  WorkoutTrackApplicationUnitTests
//
//  Created by Min-Yang Huang on 2025/12/15.
//

import Testing
import Foundation
@testable import WorkoutTrackSwiftUI

struct DateExtensionTests {

    @Test
    func startOfWeek_retrunsCorrectStartForMondayFirstCalendar() {
        let calendar = makeCalendar(firstWeekday: 2) // Monday
        
        // 2025-12-10 is a Wednesday
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        let start = date.startOfWeek(in: calendar)
        let expect = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        
        #expect(calendar.isDate(start, inSameDayAs: expect))
    }
    
    @Test
    func weekDates_returnsSevenConsecutiveDatesStartingFromStartOfWeek() {
        let calendar = makeCalendar(firstWeekday: 2) // Monday
        
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        
        let week = date.weekDates(in: calendar)
        
        #expect(week.count == 7)
        
        let expectedStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        
        for i in 0 ..< 7 {
            let epxected = calendar.date(byAdding: .day, value: i, to: expectedStart)!
            #expect(calendar.isDate(week[i], inSameDayAs: epxected))
        }
    }
    
    @Test
    func startOfMonth_returnsFirstDayOfMonth() {
        let calendar = makeCalendar()
        
        let date = getDecember15th(calendar)
        let start = date.startOfMonth(in: calendar)
        
        let expected = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        
        #expect(calendar.isDate(start, inSameDayAs: expected))
    }
    
    @Test
    func monthModel_december2025_sundayFirstCalendar() {
        let calendar = makeCalendar(firstWeekday: 1) // Sunday
        let date = getDecember15th(calendar)
        
        let model = date.monthModel(in: calendar)
        
        // December 2025 has 31 days
        #expect(model.days.count == 31)
        // December 1, 2025 is a Monday. Sunday-first calendar -> 1 leading empty cell.
        #expect(model.leadingEmptyCount == 1)
        
        let expectedFirstDay = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        
        #expect(calendar.isDate(model.days.first!, inSameDayAs: expectedFirstDay))
     }
    
    @Test
    func monthModel_leadingEmptyCount_matchesKnownCalendarFacts() {
        let cases: [(year: Int, month: Int, firstWeekday: Int, expectedLeading: Int)] = [
            (2025, 12, 1, 1), // Sunday-first -> 1 leading empty
            (2025, 12, 2, 0), // Monday-first -> 0 leading empty
        ]
        
        for testCase in cases {
            let calendar = makeCalendar(firstWeekday: testCase.firstWeekday)
            let date = getDecember15th(calendar)
            let model = date.monthModel(in: calendar)
            
            #expect(model.leadingEmptyCount == testCase.expectedLeading)
        }
    }

    //MARK: - Helpers
    private func makeCalendar(identifier: Calendar.Identifier = .gregorian, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!, firstWeekday: Int = 1) -> Calendar {
        var calendar = Calendar(identifier: identifier)
        calendar.locale = locale
        calendar.timeZone = timeZone
        calendar.firstWeekday = firstWeekday
        return calendar
    }
    
    private func getDecember15th(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!
    }
}
