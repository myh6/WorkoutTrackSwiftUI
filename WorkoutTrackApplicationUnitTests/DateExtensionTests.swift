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

    //MARK: - Helpers
    private func makeCalendar(identifier: Calendar.Identifier = .gregorian, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!, firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: identifier)
        calendar.locale = locale
        calendar.timeZone = timeZone
        calendar.firstWeekday = firstWeekday
        return calendar
    }
}
