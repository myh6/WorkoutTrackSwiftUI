//
//  Helpers.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/24.
//

import Foundation

func makeCalendar(identifier: Calendar.Identifier = .gregorian, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!, firstWeekday: Int = 1) -> Calendar {
    var calendar = Calendar(identifier: identifier)
    calendar.locale = locale
    calendar.timeZone = timeZone
    calendar.firstWeekday = firstWeekday
    return calendar
}

func getDecember15th(_ calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!
}

func date(_ calendar: Calendar = .init(identifier: .gregorian), _ year: Int, _ month: Int, _ day: Int) -> Date {
    return calendar.date(from: DateComponents(year: year, month: month, day: day))!
}
