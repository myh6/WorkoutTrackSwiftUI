//
//  Date+Extensions.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/11/30.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func isSameDay(as other: Date, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: comps) ?? self
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let daysToSubtrack = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtrack, to: self.startOfDay) ?? self.startOfDay
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
}

private let dateFormatterMonthYear: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "LLLL yyyy"
    return formatter
}()
