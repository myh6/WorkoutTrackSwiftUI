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
        spy.enqueueSession([])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        #expect(sut.state == .empty)
        #expect(sut.sections.isEmpty)
    }
    
    @MainActor
    @Test
    func load_setsStateToLoaded_whenServiceReturnsSessions() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let session = anySession(entries: [anyEntry()])
        spy.enqueueSession([[session]])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        let sections = WorkoutDayMapper.sections(
            from: session,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        #expect(sut.state == .loaded(sections))
        #expect(sut.sections == sections)
    }
    
    @MainActor
    @Test
    func load_prefetchNames_updatesSectionsTitles() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let stubbedExerciseName = "Bench Press"
        let exerciseID = UUID()
        let entry = anyEntry(exerciseID: exerciseID)
        let session = anySession(entries: [entry])
        spy.enqueueSession([[session]])
        spy.stubName(for: exerciseID, name: stubbedExerciseName)
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
        #expect(sut.sections.count == 1)
        #expect(sut.sections[0].title == stubbedExerciseName)
    }
    
    @MainActor
    @Test
    func load_prefetchesNames_doesNotRetrieveAgainWhenCacheIsAlreadyPersistent() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let stubbedExerciseName = "Bench Press"
        let exerciseID = UUID()
        let entry = anyEntry(exerciseID: exerciseID)
        let session = anySession(entries: [entry])
        spy.enqueueSession([[session]])
        spy.stubName(for: exerciseID, name: stubbedExerciseName)
        
        #expect(sut.state == .idle)
        
        await sut.load()
        await sut.load()
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .retrieve])
    }
    
    @MainActor
    @Test
    func toggleExpanded_remapsSections() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        // One random entry and one expanded entry
        let expandedEntryIDs = UUID()
        let expandedEntry = anyEntry(id: expandedEntryIDs, order: 1)
        let session = anySession(entries: [expandedEntry])
        spy.enqueueSession([[session]])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        sut.toggleExpanded(entryID: expandedEntryIDs)
        
        let expandedSections = WorkoutDayMapper.sections(
            from: session,
            expandedEntryIDs: [expandedEntryIDs],
            nameForExerciseID: { _ in nil }
        )
        #expect(sut.state == .loaded(expandedSections))
        #expect(sut.sections == expandedSections)
        
        sut.toggleExpanded(entryID: expandedEntryIDs)
        
        let collapsedSections = WorkoutDayMapper.sections(
            from: session,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        
        #expect(sut.state == .loaded(collapsedSections))
    }
    
    @MainActor
    @Test
    func toggleExpanded_doesNotOverrideWhileInLoadingState() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let expandedEntryIDs = UUID()
        let session = anySession(entries: [anyEntry(id: expandedEntryIDs)])
        spy.enqueueSession([[session]])
        
        #expect(sut.state == .idle)
        
        await sut.load()
        
        spy.suspendNextRetrieval(true)
        let task = Task {
            await sut.load()
        }
        
        await waitUntil { spy.hasPendingRetrieval }
        #expect(sut.state == .loading)
        
        sut.toggleExpanded(entryID: expandedEntryIDs)
        
        let sameSections = WorkoutDayMapper.sections(
            from: session,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        #expect(sut.sections == sameSections)
        
        spy.completeRetrievalContinuation(with: [])
        _ = await task.value
        #expect(sut.state == .empty)
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
        
        spy.enqueueSession([[session], []])
        
        await sut.load()
        
        #expect(sut.sections == sections)
        
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
        
        await waitUntil { spy.hasPendingRetrieval }
        
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
    func selectDate_removesLastSavedSections() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let newDate = getDecember28th(calendar)
        
        let oldSession = anySession(entries: [anyEntry()])
        let oldExpect = WorkoutDayMapper.sections(
            from: oldSession,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        spy.enqueueSession([[oldSession]])
        
        await sut.load()
        #expect(sut.sections == oldExpect)
        
        spy.suspendNextRetrieval(true)
        let task = Task {
            await sut.selectDate(newDate)
        }
        await waitUntil { spy.hasPendingRetrieval }
        #expect(sut.state == .loading)
        #expect(sut.sections.isEmpty)
        
        spy.completeRetrievalContinuation(with: [])
        _ = await task.value
        #expect(sut.sections.isEmpty)
    }
    
    @MainActor
    @Test
    func selectDate_updatesSections_withResultOfNextLoad() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let newDate = getDecember28th(calendar)
        
        // First load
        let sessionA = anySession(entries: [anyEntry()])
        let expectedA = WorkoutDayMapper.sections(
            from: sessionA,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        // Second load
        let sessionB = anySession(entries: [anyEntry()])
        let expectedB = WorkoutDayMapper.sections(
            from: sessionB,
            expandedEntryIDs: [],
            nameForExerciseID: { _ in nil }
        )
        spy.enqueueSession([[sessionA], [sessionB]])
        
        await sut.load()
        #expect(sut.sections == expectedA)
        
        await sut.selectDate(newDate)
        #expect(sut.sections == expectedB)
    }
    
    @MainActor
    @Test
    func selectDate_emptyExpandedEntry() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, _) = makeSUT(calendar: calendar, selectedDate: selected)
        let newDate = getDecember28th(calendar)
        let expandedID = UUID()
        
        sut.toggleExpanded(entryID: expandedID)
        
        #expect(sut.expandedEntryIDs.contains(expandedID))
        await sut.selectDate(newDate)
        #expect(sut.expandedEntryIDs.isEmpty)
    }
    
    @MainActor
    @Test
    func selectDate_sameDate_doesNotTriggerAdditionalLoads() async {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        
        #expect(spy.receivedMessages.isEmpty)
        await sut.selectDate(selected)
        #expect(spy.receivedMessages.isEmpty)
    }
    
    @MainActor
    @Test
    func toggleSetFinished_doesNotCallServiceToUpdateWhenNoMatchingSet() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let entryID = UUID(), setID = UUID(), exerciseID = UUID()
        spy.enqueueSession([[
            anySession(entries: [anyEntry(id: entryID, exerciseID: exerciseID, sets: [anySet(id: setID)])])
        ]])
        
        await sut.load()
        try await sut.toggleSetFinished(entryID: entryID, setID: UUID())
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
        
        try await sut.toggleSetFinished(entryID: UUID(), setID: setID)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func toggleSetFinished_throwsErrorOnServiceUpdateFailure() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let updateError = anyError("Update failure")
        let set = anySet(),
            exerciseID = UUID(),
            entry = anyEntry(exerciseID: exerciseID, sets: [set]),
            session = anySession(entries: [entry])
        spy.enqueueSession([[session]])
        
        await sut.load()
        
        spy.stubUpdateError(updateError)
        
        do {
            try await sut.toggleSetFinished(entryID: entry.id, setID: set.id)
            #expect(Bool(false))
        } catch {
            #expect((error as NSError) == updateError)
        }
        
        #expect(spy.receivedMessages == [
            .retrieve,
            .requestName(exerciseID),
            .updateSet((session.id, entry.id, set))
        ])
        let received = try #require(spy.receivedMessages.last)
        if case let .updateSet((_, _, receivedSet)) = received {
            #expect(receivedSet.isFinished == !set.isFinished)
        } else {
            #expect(Bool(false), "Service received set that doesn't toggle `isFinished` correctly")
        }
    }
    
    @MainActor
    @Test
    func toggleSetFinished_doesCallServiceToUpdateSetAndReloadSessions() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let set = anySet(),
            exerciseID = UUID(),
            entry = anyEntry(exerciseID: exerciseID, sets: [set]),
            session = anySession(entries: [entry])
        spy.enqueueSession([[session]])
        
        await sut.load()
        try await sut.toggleSetFinished(entryID: entry.id, setID: set.id)
        
        #expect(spy.receivedMessages == [
            .retrieve,
            .requestName(exerciseID),
            .updateSet((session.id, entry.id, set)),
            .retrieve,
        ])
    }
    
    @MainActor
    @Test
    func toggleSetFinished_updatesSectionsAfterReload_withToggledFinishedSet() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID()
        
        let setBefore = anySet(id: setID, isFinished: false)
        let setAfter = anySet(id: setID, isFinished: true)

        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(before: setBefore, after: setAfter)
        
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        
        await sut.load()
        try await sut.toggleSetFinished(entryID: entryID, setID: setID)
        
        let row = try #require(sut.sections.first?.sets.first)
        #expect(row.isFinished)
    }
    
    @MainActor
    @Test
    func toggleSetFinished_doesNotOverrideWhileInLoadingState() async throws {
        let calendar = makeCalendar()
        let selected = getDecember15th(calendar)
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: selected)
        let entryID = UUID(), setID = UUID(), exerciseID = UUID()
        let session = anySession(entries: [anyEntry(id: entryID, exerciseID: exerciseID, sets: [anySet(id: setID)])])
        spy.enqueueSession([[session]])
        
        try await assertOperationsGotIgnoredUnderSuspension(sut, spy, exerciseID: exerciseID) {
            try await sut.toggleSetFinished(entryID: entryID, setID: setID)
        }
    }
    
    @MainActor
    @Test
    func updateSetReps_doesNotCallServiceForSameRepsValue() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID(), exerciseID = UUID()
        let repsVal = 10

        let setBefore = anySet(id: setID, reps: repsVal)
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, before: setBefore, after: setBefore)
        spy.enqueueSession([[sessionBefore], [sessionAfter]])

        await sut.load()

        let row = try #require(sut.sections.first?.sets.first)
        #expect(row.reps == 10)
        try await sut.updateSetReps(entryID: entryID, setID: setID, reps: repsVal)

        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func updateSetReps_callsServiceToUpdateSet() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID(), exerciseID = UUID()
        
        let setBefore = anySet(id: setID, reps: 10)
        let setAfter = anySet(id: setID, reps: 15)
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, before: setBefore, after: setAfter)
        spy.stubName(for: exerciseID, name: "Random exercise")
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        
        await sut.load()
        
        let oldRow = try #require(sut.sections.first?.sets.first)
        #expect(oldRow.reps == 10)
        try await sut.updateSetReps(entryID: entryID, setID: setID, reps: 15)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .updateSet((sessionAfter.id, entryID, setAfter)), .retrieve])
        let newRow = try #require(sut.sections.first?.sets.first)
        #expect(newRow.reps == 15)
    }
    
    @MainActor
    @Test
    func updateSetWeight_doesNotCallServiceForSameWeightValue() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID(), exerciseID = UUID()
        let weightVal: Double = 10

        let setBefore = anySet(id: setID, weight: weightVal)
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, before: setBefore, after: setBefore)
        spy.enqueueSession([[sessionBefore], [sessionAfter]])

        await sut.load()

        let row = try #require(sut.sections.first?.sets.first)
        #expect(row.weight == 10)
        try await sut.updateSetWeight(entryID: entryID, setID: setID, weight: weightVal)

        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func updateSetWeight_callsServiceToUpdateSet() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID(), exerciseID = UUID()
        
        let setBefore = anySet(id: setID, weight: 10)
        let setAfter = anySet(id: setID, weight: 15)
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, before: setBefore, after: setAfter)
        spy.stubName(for: exerciseID, name: "Random exercise")
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        
        await sut.load()
        
        let oldRow = try #require(sut.sections.first?.sets.first)
        #expect(oldRow.weight == 10)
        try await sut.updateSetWeight(entryID: entryID, setID: setID, weight: 15)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .updateSet((sessionAfter.id, entryID, setAfter)), .retrieve])
        let newRow = try #require(sut.sections.first?.sets.first)
        #expect(newRow.weight == 15)
    }
    
    @MainActor
    @Test
    func updateSetOrder_doesNotCallServiceForSameOrderValue() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID(), exerciseID = UUID()
        let order = 1

        let setBefore = anySet(id: setID, order: order)
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, before: setBefore, after: setBefore)
        spy.enqueueSession([[sessionBefore], [sessionAfter]])

        await sut.load()

        let row = try #require(sut.sections.first?.sets.first)
        #expect(row.order == order)
        try await sut.updateSetOrder(entryID: entryID, setID: setID, order: order)

        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func updateSetOrder_callsServiceToUpdateSet() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let setID = UUID(), exerciseID = UUID()
        
        let setBefore = anySet(id: setID, order: 0)
        let setAfter = anySet(id: setID, order: 2)
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, before: setBefore, after: setAfter)
        spy.stubName(for: exerciseID, name: "Random exercise")
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        
        await sut.load()
        
        let oldRow = try #require(sut.sections.first?.sets.first)
        #expect(oldRow.order == 0)
        try await sut.updateSetOrder(entryID: entryID, setID: setID, order: 2)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .updateSet((sessionAfter.id, entryID, setAfter)), .retrieve])
        let newRow = try #require(sut.sections.first?.sets.first)
        #expect(newRow.order == 2)
    }
    
    @MainActor
    @Test
    func deleteSet_doesNotCallServiceWhenNoMatchingSet() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let entryID = UUID(), setID = UUID(), exerciseID = UUID()
        let sessions = [anySession(entries: [anyEntry(id: entryID, exerciseID: exerciseID, sets: [anySet(id: setID)])])]
        spy.stubName(for: exerciseID, name: "Random exercise")
        spy.enqueueSession([sessions])
        
        await sut.load()
                        
        try await sut.deleteSet(entryID: entryID, setID: UUID())
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
        
        try await sut.deleteSet(entryID: UUID(), setID: setID)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func deleteSet_throwsErrorOnServiceDeletionFailure() async {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let entryID = UUID(), setID = UUID(), exerciseID = UUID()
        let set = anySet(id: setID)
        let sessions = [anySession(entries: [anyEntry(id: entryID, exerciseID: exerciseID, sets: [set])])]
        let deletionError = NSError(domain: "Deletion Failure", code: 0)
        spy.enqueueSession([sessions])
        spy.stubDeleteError(deletionError)
        
        await sut.load()
        
        do {
            try await sut.deleteSet(entryID: entryID, setID: setID)
            #expect(Bool(false), "Expect deleteSet to throw")
        } catch {
            #expect((error as NSError) == deletionError)
        }
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .deleteSet(set)])
    }
    
    @MainActor
    @Test
    func deleteSet_callsServiceToDeleteAndReloadSessions() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let entryID = UUID(), setID = UUID(), exerciseID = UUID()
        let set = anySet(id: setID)
        let sessions = [anySession(entries: [anyEntry(id: entryID, exerciseID: exerciseID, sets: [set])])]
        
        spy.enqueueSession([sessions, []])
        
        await sut.load()
        
        try await sut.deleteSet(entryID: entryID, setID: setID)
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .deleteSet(set), .retrieve])
        #expect(sut.state == .empty)
    }
    
    @MainActor
    @Test
    func deleteSet_doesNotCallServiceToDeleteWhenInLoadingState() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let entryID = UUID(), setID = UUID(), exerciseID = UUID()
        let session = anySession(entries: [anyEntry(id: entryID, exerciseID: exerciseID, sets: [anySet(id: setID)])])
        spy.enqueueSession([[session]])
        
        try await assertOperationsGotIgnoredUnderSuspension(sut, spy, exerciseID: exerciseID) {
            try await sut.deleteSet(entryID: entryID, setID: setID)
        }
    }
    
    @MainActor
    @Test
    func addSet_doesNotCallServiceWhenNoMatchingEntry() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let session = anySession(entries: [anyEntry(exerciseID: exerciseID, sets: [anySet()])])
        spy.enqueueSession([[session]])
        
        await sut.load()
        try await sut.addSet(weight: 20, reps: 10, to: UUID())
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func addSet_doesNotCallServiceWhenInLoading() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, beforeOrder: 0, afterOrder: 2, sets: [anySet()])
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        spy.stubName(for: exerciseID, name: "Random Exercise")
        
        try await assertOperationsGotIgnoredUnderSuspension(sut, spy, exerciseID: exerciseID) {
            try await sut.addSet(weight: 10, reps: 10, to: entryID)
        }
    }
    
    @MainActor
    @Test
    func addSet_callsServiceToAddThenReload() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let entry = anyEntry(exerciseID: exerciseID, sets: [anySet()])
        let weightVal: Double = 20, repsVal = 10
        let session = anySession(entries: [entry])
        spy.enqueueSession([[session]])
        
        await sut.load()
        try await sut.addSet(weight: weightVal, reps: repsVal, to: entry.id)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .addSet((weightVal, repsVal, entry, session.id)), .retrieve])
    }
    
    @MainActor
    @Test
    func addSet_throwsErrorWhenServiceFinishesAddingWithFailure() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let entry = anyEntry(id: UUID(), exerciseID: exerciseID, sets: [anySet()])
        let session = anySession(entries: [entry])
        let addingError = NSError(domain: "Addition Failure", code: 0)
        spy.enqueueSession([[session]])
        spy.stubAddingError(addingError)
        
        await sut.load()
        
        do {
            try await sut.addSet(weight: 20, reps: 10, to: entry.id)
            #expect(Bool(false), "Expect deleteSet to throw")
        } catch {
            #expect((error as NSError) == addingError)
        }
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .addSet((20, 10, entry, session.id))])
    }
    
    @MainActor
    @Test
    func updateEntryOrder_doesNotCallServiceWhenNoMatchingEntry() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        spy.enqueueSession([[anySession()]])
        
        await sut.load()
        
        try await sut.updateEntryOrder(UUID(), to: 2)
        
        #expect(spy.receivedMessages == [.retrieve])
    }
    
    @MainActor
    @Test
    func updateEntryOrder_throwsErrorWhenServiceFinishesUpdateWithFailure() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let updateFailure = anyError("Update Failure")
        let exerciseID = UUID()
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, beforeOrder: 0, afterOrder: 2, sets: [anySet()])
        spy.enqueueSession([[sessionBefore]])
        spy.stubUpdateEntryError(updateFailure)
        
        await sut.load()
        
        do {
            try await sut.updateEntryOrder(entryID, to: 2)
            #expect(Bool(false), "Expect updateEntryOrder to throw error")
        } catch {
            #expect((error as NSError) == updateFailure)
        }
        
        let entry = try #require(sessionAfter.entries.first)
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .updateEntry(entry)])
    }
    
    @MainActor
    @Test
    func updateEntryOrder_callsServiceToUpdateThenReloadSessions() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, beforeOrder: 0, afterOrder: 2, sets: [anySet()])
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        spy.stubName(for: exerciseID, name: "Random Exercise")
        
        await sut.load()
        
        try await sut.updateEntryOrder(entryID, to: 2)
        
        let entry = try #require(sessionAfter.entries.first)
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .updateEntry(entry), .retrieve])
    }
    
    @MainActor
    @Test
    func updateEntryOrder_doesNotCallServiceWhenOrderIsNotChanged() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, beforeOrder: 0, afterOrder: 0, sets: [anySet()])
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        spy.stubName(for: exerciseID, name: "Random Exercise")
        
        await sut.load()
        
        try await sut.updateEntryOrder(entryID, to: 0)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID)])
    }
    
    @MainActor
    @Test
    func updateEntryOrder_doesNotCallServiceWhenInLoading() async throws {
        let calendar = makeCalendar()
        let (sut, spy) = makeSUT(calendar: calendar, selectedDate: getDecember15th(calendar))
        let exerciseID = UUID()
        let (sessionBefore, sessionAfter, entryID) = sessionsBeforeAfter(exerciseID: exerciseID, beforeOrder: 0, afterOrder: 2, sets: [anySet()])
        spy.enqueueSession([[sessionBefore], [sessionAfter]])
        spy.stubName(for: exerciseID, name: "Random Exercise")
        
        try await assertOperationsGotIgnoredUnderSuspension(sut, spy, exerciseID: exerciseID) {
            try await sut.updateEntryOrder(entryID, to: 2)
        }
    }
    
    //MARK: - Helpers
    @MainActor
    private func makeSUT(calendar: Calendar, selectedDate: Date, file: StaticString = #file, line: UInt = #line) -> (viewModel: WorkoutDayViewModel, service: WorkoutServiceSpy) {
        let service = WorkoutServiceSpy()
        let viewModel = WorkoutDayViewModel(selectedDate: selectedDate, service: service, calendar: calendar)
        return (viewModel, service)
    }
    
    private func getDecember28th(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 12, day: 28))!
    }
    
    private func getDecember30th(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 12, day: 30))!
    }
    
    /// Suspend the current task until condition is met
    @MainActor
    private func waitUntil(
        _ condition: @MainActor () -> Bool,
        file: StaticString = #file, line: UInt = #line
    ) async {
        while !condition() {
            await Task.yield()
        }
    }
    
    private func sessionsBeforeAfter(
        entryID: UUID = UUID(),
        exerciseID: UUID = UUID(),
        date: Date = Date(),
        before: WorkoutSet,
        after: WorkoutSet
    ) -> (before: WorkoutSession, after: WorkoutSession, entryID: UUID) {
        let sessionID = UUID()
        let entryBefore = anyEntry(id: entryID, exerciseID: exerciseID, sets: [before], createdAt: date)
        let entryAfter = anyEntry(id: entryID, exerciseID: exerciseID, sets: [after], createdAt: date)
        return (anySession(id: sessionID, entries: [entryBefore]), anySession(id: sessionID, entries: [entryAfter]), entryID)
    }
    
    private func sessionsBeforeAfter(
        entryID: UUID = UUID(),
        exerciseID: UUID = UUID(),
        date: Date = Date(),
        beforeOrder: Int,
        afterOrder: Int,
        sets: [WorkoutSet]
    ) -> (before: WorkoutSession, after: WorkoutSession, entryID: UUID) {
        let sessionID = UUID()
        let entryBefore = anyEntry(id: entryID, exerciseID: exerciseID, sets: sets, createdAt: date, order: beforeOrder)
        let entryAfter = anyEntry(id: entryID, exerciseID: exerciseID, sets: sets, createdAt: date, order: afterOrder)
        return (anySession(id: sessionID, entries: [entryBefore]), anySession(id: sessionID, entries: [entryAfter]), entryID)
    }
    
    @MainActor
    private func assertOperationsGotIgnoredUnderSuspension(_ sut: WorkoutDayViewModel, _ spy: WorkoutServiceSpy, exerciseID: UUID, _ operation: @escaping () async throws -> Void, fileID: String = #fileID, file: String = #filePath, line: Int = #line, column: Int = #column) async throws {
        
        await sut.load()
        
        spy.suspendNextRetrieval(true)
        let task = Task {
            await sut.load()
        }
        
        await waitUntil { spy.hasPendingRetrieval }
        #expect(sut.state == .loading)
        
        try await operation()
        
        spy.completeRetrievalContinuation(with: [])
        _ = await task.value
        #expect(sut.state == .empty)
        
        #expect(spy.receivedMessages == [.retrieve, .requestName(exerciseID), .retrieve], sourceLocation: SourceLocation(fileID: fileID, filePath: file, line: line, column: column))
    }
    
    private class WorkoutServiceSpy: WorkoutDayServicing {
        enum Message: Equatable {
            case retrieve,
                 updateSet((session: UUID, entry: UUID, set: WorkoutSet)),
                 requestName(UUID),
                 deleteSet(WorkoutSet),
                 addSet((weight: Double, reps: Int, entry: WorkoutEntry, sessionID: UUID)),
                 updateEntry(WorkoutEntry)
                
            
            static func ==(_ lhs: Message, _ rhs: Message) -> Bool {
                switch (lhs, rhs) {
                case (.retrieve, .retrieve):
                    return true
                case let (.updateSet(firstCtx), .updateSet(secondCtx)):
                    return firstCtx.session == secondCtx.session && firstCtx.entry == secondCtx.entry && firstCtx.set.id == secondCtx.set.id // The rest of the properties need to be checked separately
                case let (.requestName(firstID), .requestName(secondID)):
                    return firstID == secondID
                case let (.deleteSet(firstSet), .deleteSet(secondSet)):
                    return firstSet == secondSet
                case let (.updateEntry(firstEntry), .updateEntry(secondEntry)):
                    return firstEntry == secondEntry
                case let (.addSet(firstAddition), .addSet(secondAddition)):
                    return firstAddition.weight == secondAddition.weight && firstAddition.reps == firstAddition.reps && firstAddition.entry == secondAddition.entry && firstAddition.sessionID == secondAddition.sessionID
                default:
                    return false
                }
            }
        }
        
        private(set) var receivedMessages = [Message]()
        private(set) var receivedQuery = [SessionQueryDescriptor]()

        private var stubbedRetrievalError: Error?
        private var shouldSuspend = false
        private var retrievalContinuation: CheckedContinuation<[WorkoutSession], Error>?
        
        private(set) var hasPendingRetrieval = false
        
        private var sessionsQueue: [[WorkoutSession]] = []
        func enqueueSession(_ batches: [[WorkoutSession]]) {
            sessionsQueue.append(contentsOf: batches)
        }
        
        func suspendNextRetrieval(_ val: Bool) {
            shouldSuspend = val
        }
        
        func completeRetrievalContinuation(with sessions: [WorkoutSession]) {
            hasPendingRetrieval = false
            retrievalContinuation?.resume(returning: sessions)
            retrievalContinuation = nil
        }
        
        func completeRetrievalContinuation(with error: Error) {
            hasPendingRetrieval = false
            retrievalContinuation?.resume(throwing: error)
            retrievalContinuation = nil
        }
        
        func stubRetrievalError(_ error: Error) {
            stubbedRetrievalError = error
        }
        
        func stubName(for id: UUID, name: String) {
            stubbedNames[id] = name
        }
        
        var stubbedNames: [UUID: String] = [:]
        func getExerciseName(from id: UUID) async throws -> String? {
            receivedMessages.append(.requestName(id))
            return stubbedNames[id]
        }
        
        func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutTrack.WorkoutSession] {
            if let query {
                receivedQuery.append(query)
            }
            receivedMessages.append(.retrieve)
            if let stubbedRetrievalError {
                throw stubbedRetrievalError
            }
            
            if shouldSuspend {
                shouldSuspend = false
                return try await withCheckedThrowingContinuation { cont in
                    self.retrievalContinuation = cont
                    self.hasPendingRetrieval = true
                }
            } else {
                return sessionsQueue.isEmpty ? [] : sessionsQueue.removeFirst()
            }
        }
        
        private var updateError: Error?
        func stubUpdateError(_ error: Error) {
            updateError = error
        }
        
        func updateSet(_ set: WorkoutSet, within entry: WorkoutEntry, and session: UUID) async throws {
            receivedMessages.append(.updateSet((session, entry.id, set)))
            if let error = updateError { throw error }
        }
        
        private var deleteError: Error?
        func stubDeleteError(_ error: Error) {
            deleteError = error
        }
        func deleteSet(_ set: WorkoutSet) async throws {
            receivedMessages.append(.deleteSet(set))
            if let error = deleteError { throw error }
        }
        
        private var addingError: Error?
        func stubAddingError(_ error: Error) {
            addingError = error
        }
        func addSets(_ sets: [WorkoutSet], to entry: WorkoutEntry, within session: UUID) async throws {
            for set in sets {
                receivedMessages.append(.addSet((set.weight, set.reps, entry, session)))
            }
            if let error = addingError { throw error }
        }
        
        func stubUpdateEntryError(_ error: Error) {
            updateEntryError = error
        }
        
        private var updateEntryError: Error?
        func updateEntry(_ entry: WorkoutEntry, within session: WorkoutSession) async throws {
            receivedMessages.append(.updateEntry(entry))
            if let error = updateEntryError { throw error }
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

func anySet(id: UUID = UUID(), reps: Int = 0, weight: Double = 0, isFinished: Bool = false, order: Int = 0) -> WorkoutSet {
    WorkoutSet(id: id, reps: reps, weight: weight, isFinished: isFinished, order: order)
}

func anyError(_ domain: String = "Any error", _ code: Int = 0) -> NSError {
    return NSError(domain: domain, code: code)
}
