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
        
        await sut.load()
        
        let query = try #require(spy.receivedQuery)
        let range = try #require(query.dateRange)
        
        let start = selected.startOfDay(in: calendar)
        #expect(range.lowerBound == start)
        
        let expectedUpper = selected.addingDays(1, in: calendar).addingTimeInterval(-1)
        #expect(range.upperBound == expectedUpper)
    }
    
    @Test
    func load_setsStateToEmpty_whenServiceReturnsNoSessions() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        spy.stubSessions([])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        #expect(sut.state == .empty)
    }
    
    @Test
    func load_setsStateToLoaded_whenServiceReturnsSessions() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        spy.stubSessions([anySession()])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        #expect(sut.state == .loaded)
    }
    
    @Test
    func load_setsStateToFailed_whenServiceThrows() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        spy.stubRetrievalError(anyError("testing crashes"))
        
        await sut.load()
        
        if case .failed(let message) = sut.state {
            #expect(message.contains("testing crashes"))
        } else {
            #expect(Bool(false))
        }
    }
    
    @Test
    func load_setsStateToLoading_whileAwaitingService() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        spy.suspendNextRetrieval(true)
        
        let task = Task {
            await sut.load()
        }
        await Task.yield()
        
        #expect(sut.state == .loading)
        
        spy.completeRetrievalContinuation(with: [])
        _ = await task.value
        
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
        private var stubbedRetrievalError: Error?
        private var shouldSuspend = false
        private var retrievalContinunation: CheckedContinuation<[WorkoutSession], Error>?
        
        func suspendNextRetrieval(_ val: Bool) {
            shouldSuspend = val
        }
        
        func completeRetrievalContinuation(with sessions: [WorkoutSession]) {
            retrievalContinunation?.resume(returning: sessions)
            retrievalContinunation = nil
        }
        
        func completeRetrievalContinuation(with error: Error) {
            retrievalContinunation?.resume(throwing: error)
            retrievalContinunation = nil
        }
        
        func stubSessions(_ sessions: [WorkoutSession]) {
            stubbedSessions = sessions
        }
        
        func stubRetrievalError(_ error: Error) {
            stubbedRetrievalError = error
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
            
            if let stubbedRetrievalError {
                throw stubbedRetrievalError
            }
            
            if shouldSuspend {
                return try await withCheckedThrowingContinuation { cont in
                    self.retrievalContinunation = cont
                }
            } else {
                return stubbedSessions
            }
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

func anyError(_ domain: String = "Any error", _ code: Int = 0) -> NSError {
    return NSError(domain: domain, code: code)
}
