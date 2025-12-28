//
//  WorkoutDayViewModelTests.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import Foundation
import Testing
import WorkoutTrack
@testable import WorkoutTrackSwiftUI

struct WorkoutDayViewModelTests {
    
    @Test
    func load_queryServiceWithSelectedDateDayRange() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        
        try await sut.load()
        
        let query = try #require(spy.receivedQuery)
        let range = try #require(query.dateRange)
        
        let start = selected.startOfDay(in: calendar)
        #expect(range.lowerBound == start)
        
        let expectedUpper = selected.addingDays(1, in: calendar).addingTimeInterval(-1)
        #expect(range.upperBound == expectedUpper)
    }
    
    @Test
    func load_setsStateToEmpty_whenServiceReturnsNoSessions() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        spy.stubSessions([])
        
        #expect(sut.state == .idle)
        
        try await sut.load()
        
        #expect(sut.state == .empty)
    }
    
    //MARK: - Helpers
    private func makeSUT(calendar: Calendar, selectedDate: Date, file: StaticString = #file, line: UInt = #line) -> (viewModel: WorkoutDayViewModel, service: WorkoutServiceSpy) {
        let service = WorkoutServiceSpy()
        let viewModel = WorkoutDayViewModel(selectedDate: selectedDate, service: service, calendar: calendar)
        return (viewModel, service)
    }
    
    private class WorkoutServiceSpy: WorkoutTracking {
        private(set) var receivedQuery: SessionQueryDescriptor?
        private var stubbedSessions: [WorkoutSession] = []
        
        func stubSessions(_ sessions: [WorkoutSession]) {
            stubbedSessions = sessions
        }
        
        func getExerciseName(from id: UUID) async throws -> String? {
            return nil
        }
        
        func addCustomExercise(_ exercise: CustomExercise) async throws {
        }
        
        func deleteExercise(_ exercise: CustomExercise) async throws {
        }
        
        func updateExercise(_ exercise: CustomExercise) async throws {
        }
        
        func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutTrack.WorkoutSession] {
            receivedQuery = query
            return stubbedSessions
        }
        
        func addSessions(_ sessions: [WorkoutSession]) async throws {
        }
        
        func updateSession(_ session: WorkoutSession) async throws {
        }
        
        func deleteSession(_ session: WorkoutSession) async throws {
        }
        
        func addEntry(_ entries: [WorkoutEntry], to session: WorkoutSession) async throws {
        }
        
        func updateEntry(_ entry: WorkoutEntry, within session: WorkoutSession) async throws {
        }
        
        func deleteEntry(_ entry: WorkoutEntry) async throws {
        }
        
        func addSets(_ sets: [WorkoutSet], to entry: WorkoutEntry, within session: UUID) async throws {
        }
        
        func updateSet(_ set: WorkoutSet, within entry: WorkoutEntry, and session: UUID) async throws {
        }
        
        func deleteSet(_ set: WorkoutSet) async throws {
        }
    }
}

func anySession(id: UUID = UUID(), date: Date = Date(), entries: [WorkoutEntry] = []) -> WorkoutSession {
    return WorkoutSession(id: id, date: date, entries: entries)
}
