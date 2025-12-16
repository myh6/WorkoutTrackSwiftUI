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
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2 // Monday
        
        // 2025-12-10 is a Wednesday
        let date = calendar.date(from: DateComponents(year: 2025, month: 12, day: 10))!
        let start = date.startOfWeek(in: calendar)
        let expect = calendar.date(from: DateComponents(year: 2025, month: 12, day: 8))!
        
        #expect(calendar.isDate(start, inSameDayAs: expect))
    }

}
