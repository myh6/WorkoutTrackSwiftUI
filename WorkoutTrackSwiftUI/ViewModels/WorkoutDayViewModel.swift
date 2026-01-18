//
//  WorkoutDayViewModel.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import Foundation
import WorkoutTrack

struct ExerciseSection: Equatable {
    let id: UUID
    let title: String
    let sets: [SetRow]
    let isExpanded: Bool
}

struct SetRow: Equatable {
    let id: UUID
    let reps: Int
    let weight: Double
    let isFinished: Bool
    let order: Int
}

@MainActor
class WorkoutDayViewModel: ObservableObject {
    
    @Published private(set) var selectedDate: Date
    private let service: WorkoutTracking
    private let calendar: Calendar
    
    private let resolveExerciseName: (UUID) -> String?
    
    enum State: Equatable {
        case idle, empty, loading, loaded([ExerciseSection]), failed(String)
    }
    
    @Published private(set) var state: State = .idle
    @Published private(set) var sessions: [ExerciseSection] = []
    @Published private(set) var expandedEntryIDs: Set<UUID> = []
    init(selectedDate: Date,
         service: WorkoutTracking,
         calendar: Calendar,
         resolveExerciseName: @escaping (UUID) -> String?) {
        self.selectedDate = selectedDate
        self.service = service
        self.calendar = calendar
        self.resolveExerciseName = resolveExerciseName
    }
    
    func load() async {
        state = .loading
        let query = QueryBuilder()
            .filterDateRange(selectedDate.dayRange(in: calendar))
            .build()
        do {
            sessions = try await service.retrieveSessions(by: query)
                .flatMap { session in
                WorkoutDayMapper.sections(from: session, expandedEntryIDs: expandedEntryIDs, nameForExerciseID: resolveExerciseName)
            }
            state = sessions.isEmpty ? .empty : .loaded(sessions)
        } catch {
            state = .failed(String(describing: error))
        }
    }
    
    func selectDate(_ newDate: Date) async {
        guard newDate != selectedDate else { return }
        selectedDate = newDate
        await load()
    }
}
