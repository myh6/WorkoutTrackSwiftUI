//
//  CalendarViewModel.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/16.
//

import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    
    enum Mode {
        case weekly, monthly
    }
    
    @Published var anchorDate: Date
    @Published var mode: Mode
    
    private let calendar: Calendar
    
    init(calendar: Calendar, mode: Mode, anchorDate: Date, selectedDate: Date) {
        self.calendar = calendar
        self.mode = mode
        self.anchorDate = anchorDate
    }
    
    var weekDates: [Date] {
        anchorDate.weekDates(in: calendar)
    }
    
    func moveNext() {
        move(by: 1)
    }
    
    func movePrevious() {
        move(by: -1)
    }
    
    private func move(by delta: Int) {
        switch mode {
        case .weekly:
            anchorDate = calendar.date(byAdding: .day, value: 7 * delta, to: anchorDate) ?? anchorDate
        case .monthly:
            anchorDate = calendar.date(byAdding: .month, value: delta, to: anchorDate) ?? anchorDate
        }
    }
}
