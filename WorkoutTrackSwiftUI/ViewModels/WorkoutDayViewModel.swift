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
        case idle, empty, loaded
    }
    
    private(set) var state: State = .idle
    
    init(selectedDate: Date, service: WorkoutTracking, calendar: Calendar) {
        self.selectedDate = selectedDate
        self.service = service
        self.calendar = calendar
    }
    
    func load() async throws {
        let query = QueryBuilder()
            .filterDateRange(selectedDate.dayRange(in: calendar))
            .build()
        let sessions = try await service.retrieveSessions(by: query)
        state = sessions.isEmpty ? .empty : .loaded
    }
    
}
