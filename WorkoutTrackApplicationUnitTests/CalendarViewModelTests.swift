//
//  CalendarViewModelTests.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/16.
//

import Testing
import Foundation
@testable import WorkoutTrackSwiftUI

struct CalendarViewModelTests {
    @Test
    @MainActor
    func moveNext_inWeeklyMode_advancesAnchorBySevenDays() {
        let calendar = makeCalendar()
        let anchor = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: anchor, selectedDate: anchor)
        
        vm.moveNext()
        
        let expected = calendar.date(byAdding: .day, value: 7, to: anchor)!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expected))
    }
    
    @Test
    @MainActor
    func movePrevious_inWeeklyMode_rewindsAnchorBySevenDays() {
        let calendar = makeCalendar()
        let anchor = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: anchor, selectedDate: anchor)
        
        vm.movePrevious()
        
        let expected = calendar.date(byAdding: .day, value: -7, to: anchor)!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expected))
    }
    
    @Test
    @MainActor
    func moveNext_inMonthlyMode_advancesAnchorByOneMonth() {
        let calendar = makeCalendar()
        let anchor = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        let vm = CalendarViewModel(calendar: calendar, mode: .monthly, anchorDate: anchor, selectedDate: anchor)
        
        vm.moveNext()
        
        let expected = calendar.date(from: DateComponents(year: 2026, month: 1, day: 10))!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expected))
    }
    
    //MARK: - Helpers
    private func makeCalendar(identifier: Calendar.Identifier = .gregorian, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!, firstWeekday: Int = 1) -> Calendar {
        var calendar = Calendar(identifier: identifier)
        calendar.locale = locale
        calendar.timeZone = timeZone
        calendar.firstWeekday = firstWeekday
        return calendar
    }
}
