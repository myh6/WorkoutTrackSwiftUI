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
    
    @MainActor
    @Test
    func load_queryServiceWithSelectedDateDayRange() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        
        await sut.load()
        
        let query = try #require(spy.receivedQuery.first)
        let range = try #require(query.dateRange)
        
        let start = selected.startOfDay(in: calendar)
        #expect(range.lowerBound == start)
        
        let expectedUpper = selected.addingDays(1, in: calendar).addingTimeInterval(-1)
        #expect(range.upperBound == expectedUpper)
    }
    
    @MainActor
    @Test
    func load_setsStateToEmpty_whenServiceReturnsNoSessions() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        spy.stubSessions([])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        #expect(sut.state == .empty)
        #expect(sut.sessions.isEmpty)
    }
    
    @MainActor
    @Test
    func load_setsStateToLoaded_whenServiceReturnsSessions() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let resolver: (UUID) -> String? = { _ in nil }
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected, resolveExerciseName: resolver)
        let session = anySession(entries: [anyEntry()])
        let sections = WorkoutDayMapper.sections(
            from: session,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        spy.stubSessions([session])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        #expect(sut.state == .loaded(sections))
        #expect(sut.sessions == sections)
    }
    
    @MainActor
    @Test
    func load_empty_clearsSessions() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let session = anySession()
        let sections = WorkoutDayMapper.sections(
            from: session,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        
        spy.stubSessions([session])
        
        await sut.load()
        
        #expect(sut.sessions == sections)
        
        spy.stubSessions([])
        
        await sut.load()
        
        #expect(sut.state == .empty)
    }
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
    @Test
    func selectDate_updatesQueryDateRange_automaticallyTriggersNextLoad() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let newDate = getDecember28th(calendar)
        
        #expect(spy.receivedQuery.isEmpty)
        await sut.selectDate(newDate)
        
        let query = try #require(spy.receivedQuery.first)
        let range = try #require(query.dateRange)
        
        let start = newDate.startOfDay(in: calendar)
        #expect(range.lowerBound == start)
        
        let expectedUpper = newDate.addingDays(1, in: calendar).addingTimeInterval(-1)
        #expect(range.upperBound == expectedUpper)
    }
    
    @MainActor
    @Test
    func selectDate_sameDate_doesNotTriggerAdditionalLoads() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        
        #expect(spy.receivedQuery.isEmpty)
        await sut.selectDate(selected)
        #expect(spy.receivedQuery.isEmpty)
    }
    
    //MARK: - Helpers
    @MainActor
    private func makeSUT(calendar: Calendar, selectedDate: Date, resolveExerciseName: @escaping (UUID) -> String? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (viewModel: WorkoutDayViewModel, service: WorkoutServiceSpy) {
        let service = WorkoutServiceSpy()
        let viewModel = WorkoutDayViewModel(selectedDate: selectedDate, service: service, calendar: calendar, resolveExerciseName: resolveExerciseName)
        return (viewModel, service)
    }
    
    private func getDecember28th(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 12, day: 28))!
    }
    
    private func getDecember30th(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 12, day: 30))!
    }
    
    private class WorkoutServiceSpy: WorkoutTracking {
        private(set) var receivedQuery: [SessionQueryDescriptor] = []
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
            if let query {
                receivedQuery.append(query)
            }
            
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

func anySection(id: UUID = UUID(), title: String = "", sets: [SetRow] = [], isExpanded: Bool = true) -> ExerciseSection {
    ExerciseSection(id: id, title: title, sets: sets, isExpanded: isExpanded)
}

func anyRow(id: UUID = UUID(), reps: Int = 0, weight: Double = 0, isFinished: Bool = true, order: Int = 0) -> SetRow {
    SetRow(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
}

func anySession(id: UUID = UUID(), date: Date = Date(), entries: [WorkoutEntry] = []) -> WorkoutSession {
    return WorkoutSession(id: id, date: date, entries: entries)
}

func anyEntry(id: UUID = UUID(), exerciseID: UUID = UUID(), sets: [WorkoutSet] = [], createdAt: Date = Date(), order: Int = 0) -> WorkoutEntry {
    WorkoutEntry(id: id, exerciseID: exerciseID, sets: sets, createdAt: createdAt, order: order)
}

func anyError(_ domain: String = "Any error", _ code: Int = 0) -> NSError {
    return NSError(domain: domain, code: code)
}
