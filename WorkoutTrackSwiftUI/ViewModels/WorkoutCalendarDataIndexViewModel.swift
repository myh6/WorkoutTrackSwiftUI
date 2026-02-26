//
//  WorkoutCalendarDataIndexViewModel.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/2/26.
//

import Foundation
import WorkoutTrack

final class WorkoutCalendarDataIndexViewModel {
    private let service: WorkoutDayServicing
    private let calendar: Calendar
    private var daysWithData = Set<Date>() // store start of day
    
    init(service: WorkoutDayServicing, calendar: Calendar) {
        self.service = service
        self.calendar = calendar
    }
    
    func hasData(_ date: Date) -> Bool {
        let start = date.startOfDay(in: calendar)
        return daysWithData.contains(start)
    }
    
    func prefetch(in range: ClosedRange<Date>) async {
        let query = QueryBuilder()
            .filterDateRange(range)
            .build()
        if let sessions = try? await service.retrieveSessions(by: query) {
            for session in sessions {
                daysWithData.insert(session.date.startOfDay(in: calendar))
            }
        }
    }
}
