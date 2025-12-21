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
    
    @Test
    @MainActor
    func movePrevious_inMonthlyMode_rewindsAnchorByOneMonth() {
        let calendar = makeCalendar()
        let anchor = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        let vm = CalendarViewModel(calendar: calendar, mode: .monthly, anchorDate: anchor, selectedDate: anchor)
        
        vm.movePrevious()
        
        let expected = calendar.date(from: DateComponents(year: 2025, month: 11, day: 10))!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expected))
    }
    
    @Test
    @MainActor
    func selectDate_inWeeklyMode_updatesSelectedDate_andSnapsAnchorToSelectedDatesWeek() {
        let calendar = makeCalendar(firstWeekday: 2) // Monday
        let anchor = getDecember10th(calendar)
        let newDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 12))!
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: anchor, selectedDate: anchor)
        
        vm.selectDate(newDate)
        
        #expect(vm.selectedDate == newDate)
        
        // December 12, 2025 is Friday --> Monday-first week start should be on December 8th
        let expectedWeekStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expectedWeekStart))
    }
    
    @Test
    @MainActor
    func selectDate_inMonthlyMode_updatesSelectedDate_andSnapsAnchorToSelectedDatesMonth() {
        let calendar = makeCalendar(firstWeekday: 1) // Sunday
        let anchor = getDecember10th(calendar)
        let newDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 12))!
        let vm = CalendarViewModel(calendar: calendar, mode: .monthly, anchorDate: anchor, selectedDate: anchor)
        
        vm.selectDate(newDate)
        
        #expect(vm.selectedDate == newDate)
        
        let expectedWeekStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expectedWeekStart))
    }
    
    @Test
    @MainActor
    func isSelected_returnsTrueForSameDaysAsSelectedDate() throws {
        let calendar = makeCalendar()
        let anchor = getDecember10th(calendar)
        let selected = calendar.date(from: DateComponents(year: 2025, month: 12, day: 12))!
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: anchor, selectedDate: selected)
        
        let otherDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        
        #expect(vm.isSelected(otherDate) == false)
        #expect(vm.isSelected(anchor) == false)
        #expect(vm.isSelected(selected) == true)
    }
    
    @Test
    @MainActor
    func weekDates_exposesSevenDatesFromAnchor() throws {
        let calendar = makeCalendar(firstWeekday: 2) // Monday
        let anchor = getDecember10th(calendar)
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: anchor, selectedDate: anchor)
        
        let dates = vm.weekDates
        
        try #require(dates.count == 7)
        #expect(calendar.component(.weekday, from: dates.first!) == 2)
    }
    
    @Test
    @MainActor
    func weekdaySymbols_exposesShortWeekdayNamesAlwaysStartsWithSundayRegardlessOfFirstWeekday() throws {
        let calendar = makeCalendar(firstWeekday: 2) // Monday
        let date = getDecember10th(calendar)
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: date, selectedDate: date)
        
        let symbols = vm.weekdaySymbols
        
        try #require(symbols.count == 7)
        #expect(symbols == ["S", "M", "T", "W", "T", "F", "S"])
    }
    
    @Test
    @MainActor
    func monthModel_exposesCorrectDaysAndLeadingEmptyCount() throws {
        let calendar = makeCalendar(firstWeekday: 1) // Sunday
        let anchor = getDecember10th(calendar)
        let vm = CalendarViewModel(calendar: calendar, mode: .monthly, anchorDate: anchor, selectedDate: anchor)
        
        let model = vm.monthModel
        
        #expect(model.days.count == 31)
        #expect(model.leadingEmptyCount == 1) // December 1, 2025 is Monday --> 1 leading blank for Sunday
        
        let expectedFirstDay = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        try #require(model.days.first != nil)
        #expect(calendar.isDate(model.days.first!, inSameDayAs: expectedFirstDay))
    }
    
    @Test
    @MainActor
    func setMode_toWeekly_updateModes_andSnapsAnchorToSelectedDatesWeek() {
        let calendar = makeCalendar(firstWeekday: 2) // Monday
        let anchor = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        let selected = getDecember10th(calendar)
        
        let vm = CalendarViewModel(calendar: calendar, mode: .monthly, anchorDate: anchor, selectedDate: selected)
        
        vm.setMode(.weekly)
        
        #expect(vm.mode == .weekly)
        
        // December 10, 2025 is Wednesday --> Monday-first week start should be on December 8th
        let expectedWeekStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expectedWeekStart))
    }
    
    @Test
    @MainActor
    func setMode_toMonthly_updateMode_andSnapsAnchorToSelectedDatesMonth() {
        let calendar = makeCalendar(firstWeekday: 1) // Sunday
        let anchor = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let selected = getDecember10th(calendar)
        
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: anchor, selectedDate: selected)
        
        vm.setMode(.monthly)
        
        #expect(vm.mode == .monthly)
        
        let expectedWeekStart = calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!
        #expect(calendar.isDate(vm.anchorDate, inSameDayAs: expectedWeekStart))
    }
    
    @Test
    @MainActor
    func titleText_usesMonthYear() {
        let calendar = makeCalendar()
        let date = getDecember10th(calendar)
        let vm = CalendarViewModel(calendar: calendar, mode: .weekly, anchorDate: date, selectedDate: date)
        
        let weeklyTitle = vm.titleText
        #expect(weeklyTitle == "December 2025")
        
        vm.setMode(.monthly)
        
        let monthlyTitle = vm.titleText
        print(vm.anchorDate)
        #expect(monthlyTitle == "December 2025")
    }
    
    //MARK: - Helpers
    private func makeCalendar(identifier: Calendar.Identifier = .gregorian, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!, firstWeekday: Int = 1) -> Calendar {
        var calendar = Calendar(identifier: identifier)
        calendar.locale = locale
        calendar.timeZone = timeZone
        calendar.firstWeekday = firstWeekday
        return calendar
    }
    
    private func getDecember10th(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
    }
}
