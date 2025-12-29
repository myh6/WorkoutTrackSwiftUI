//
//  WorkoutDayViewModel.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import Foundation
import WorkoutTrack

class WorkoutDayViewModel: ObservableObject {
    
    @Published private(set) var selectedDate: Date
    private let service: WorkoutTracking
    private let calendar: Calendar
    
    enum State: Equatable {
        case idle, empty, loading, loaded, failed(String)
    }
    
    @Published private(set) var state: State = .idle
    
    init(selectedDate: Date, service: WorkoutTracking, calendar: Calendar) {
        self.selectedDate = selectedDate
        self.service = service
        self.calendar = calendar
    }
    
    func load() async {
        state = .loading
        let query = QueryBuilder()
            .filterDateRange(selectedDate.dayRange(in: calendar))
            .build()
        do {
            let sessions = try await service.retrieveSessions(by: query)
            state = sessions.isEmpty ? .empty : .loaded
        } catch {
            state = .failed(String(describing: error))
        }
    }
    
    func selectDate(_ newDate: Date) async {
        selectedDate = newDate
        await load()
    }
}
