//
//  Date+Extensions.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/11/30.
//

import Foundation

extension Date {
    func isSameDay(as other: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
    
    func addingDays(_ days: Int, in calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    var monthYeraTitle: String {
        dateFormatterMonthYear.string(from: self)
    }
    
    func numberOfDaysInMonth(in calendar: Calendar = .current) -> Int {
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return 0
        }
        return range.count
    }
    
    func startOfDay(in calendar: Calendar) -> Date {
        calendar.startOfDay(for: self)
    }
    
    func dayRange(in calendar: Calendar) -> ClosedRange<Date> {
        let start = calendar.startOfDay(for: self)
        let end = self.addingDays(1, in: calendar).addingTimeInterval(-1)
        return start...end
    }
    
    func startOfWeek(in calendar: Calendar) -> Date {
        let startOfDay = calendar.startOfDay(for: self)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysToSubtract = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay) ?? startOfDay
    }
    
    func weekDates(in calendar: Calendar) -> [Date] {
        let start = startOfWeek(in: calendar)
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
    
    func startOfMonth(in calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: comps) ?? self
    }
    
    func monthModel(in calendar: Calendar) -> CalendarMonthModel {
        let start = startOfMonth(in: calendar)
        let range = calendar.range(of: .day, in: .month, for: start) ?? (1..<1)
        let days = range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
        
        let weekdayOfFirst = calendar.component(.weekday, from: start)
        let leadingEmpty = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        return CalendarMonthModel(days: days, leadingEmptyCount: leadingEmpty)
    }
    
    func monthYearTitle(in calendar: Calendar) -> String {
        var style = Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone)
            .month(.wide)
            .year()
            
        
        if let locale = calendar.locale {
            style = style.locale(locale)
        }
        
        return formatted(style)
    }
}

struct CalendarMonthModel {
    let days: [Date]
    let leadingEmptyCount: Int
}

private let dateFormatterMonthYear: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    return formatter
}()
