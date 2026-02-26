//
//  WorkoutCalendarDataIndexViewModelTests.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/2/24.
//

final class WorkoutCalendarDataIndexViewModel {
    
    func hasData(_ date: Date) -> Bool {
        return false
    }
}

import Testing
import Foundation

class WorkoutCalendarDataIndexViewModelTests {
    
    @Test
    func hasData_returnsFalse_beforePrefetch() {
        let sut = WorkoutCalendarDataIndexViewModel()
        #expect(sut.hasData(Date()) == false)
    }
}

