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
    @Published var selectedDate: Date
    @Published var mode: Mode
    
    private let calendar: Calendar
    
    init(calendar: Calendar, mode: Mode, anchorDate: Date, selectedDate: Date) {
        self.calendar = calendar
        self.mode = mode
        self.anchorDate = anchorDate
        self.selectedDate = selectedDate
    }
    
    var weekDates: [Date] {
        anchorDate.weekDates(in: calendar)
    }
    
    var monthModel: CalendarMonthModel {
        anchorDate.monthModel(in: calendar)
    }
    
    var titleText: String {
        anchorDate.monthYearTitle(in: calendar)
    }
    
    func moveNext() {
        move(by: 1)
    }
    
    func movePrevious() {
        move(by: -1)
    }
    
    func setMode(_ newMode: Mode) {
        mode = newMode
        
        switch newMode {
        case .weekly:
            anchorDate = selectedDate.startOfWeek(in: calendar)
        case .monthly:
            anchorDate = selectedDate.startOfMonth(in: calendar)
        }
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
