//
//  WorkoutTrackIntegrationTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/17.
//

import XCTest
@testable import WorkoutTrack
import SwiftData

final class WorkoutTrackIntegrationTests: XCTestCase {
    
    func test_getExerciseName_deliversNilWhenNoMatchingID() async throws {
        let sut = try makeSUT()
        let id = UUID()
        
        try await sut.addCustomExercise(anyExercise())
        let retrieved = try await sut.getExerciseName(from: id)
        
        XCTAssertNil(retrieved)
    }
    
    func test_getExerciseName_deliversNameWithMatchingID() async throws {
        let sut = try makeSUT()
        let pushUpId = getPushUpID()
        let custom = anyExercise(name: "Random Exercise", category: .abs)
        
        try await sut.addCustomExercise(custom)
        let presaved = try await sut.getExerciseName(from: pushUpId)
        let retrievedCustom = try await sut.getExerciseName(from: custom.id)
        
        XCTAssertEqual(presaved, "Push-Up")
        XCTAssertEqual(retrievedCustom, custom.name)
    }

    func test_addCustomExercise_andUseInWorkoutSession() async throws {
        let sut = try makeSUT()
        let exercise = anyExercise(name: "Zercher Squat", category: .legs)
        let entry = anyEntry(exercise: exercise.id, sets: [anySet()])
        
        try await sut.addCustomExercise(exercise)
        try await sut.addEntry([entry], to: anySession())
        
        let retrieved = try await sut.retrieveSessions(by: nil).flatMap(\.entries)
        XCTAssertEqual(retrieved.count, 1)
        let retrievedEntry = try XCTUnwrap(retrieved.first)
        XCTAssertEqual(retrievedEntry.exerciseID, exercise.id)
    }
    
    func test_addSessions_onSameDay_mergesEntriesIntoExistingSession() async throws {
        let sut = try makeSUT()
        let date = Date()
        let oldEntries = [anyEntry(createdAt: date)]
        let newEntries = [anyEntry(createdAt: date.adding(minutes: 1)), anyEntry(createdAt: date.adding(minutes: 2))]
        let oldSession = anySession(date: date, entries: oldEntries)
        let newSession = anySession(date: date.adding(minutes: 40), entries: newEntries)
        
        try await sut.addSessions([oldSession])
        try await sut.addSessions([newSession])
        
        let expected = anySession(id: oldSession.id, date: oldSession.date, entries: oldEntries + newEntries)
        
        let retrieved = try await sut.retrieveSessions(by: .none)
        XCTAssertEqual(retrieved, [expected])
    }
    
    func test_addEntry_ignoresEntriesWithUnknownExerciseID() async throws {
        let sut = try makeSUT()
        let knownExercise = anyExercise()
        let entry = [anyEntry(exercise: knownExercise.id), anyEntry(), anyEntry(exercise: getPushUpID()), anyEntry()]
        
        try await sut.addCustomExercise(knownExercise)
        try await sut.addEntry(entry, to: anySession())
        
        let retrieved = try await sut.retrieveSessions(by: nil).flatMap(\.entries)
        print(retrieved)
        XCTAssertEqual(retrieved.count, 2)
    }
    
    func test_addEntry_forDeletedExercise_shouldBeSkipped() async throws {
        let sut = try makeSUT()
        let exercise = anyExercise()
        
        try await sut.addCustomExercise(exercise)
        try await sut.deleteExercise(exercise)
        try await sut.addEntry([anyEntry(exercise: exercise.id, sets: [anySet()])], to: anySession())
        
        let retrieved = try await sut.retrieveSessions(by: nil)
        XCTAssertTrue(retrieved.isEmpty)
    }
    
    func test_addEntry_mergesSetsIfEntriesHaveTheSameExerciseInTheSameSession() async throws {
        let sut = try makeSUT()
        let exerciseId = getPushUpID()
        let entry1 = anyEntry(exercise: exerciseId, sets: [anySet()])
        let entry2 = anyEntry(exercise: exerciseId, sets: [anySet()])
        let sameSession = anySession()
        
        try await sut.addEntry([entry1], to: sameSession)
        try await sut.addEntry([entry2], to: sameSession)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        XCTAssertEqual(retrieved, [mergeEntriesToOne(entry1, entry2)])
    }
    
    func test_addEntry_canHaveTheSameExerciseIdButInDifferentSession() async throws {
        let sut = try makeSUT()
        let exerciseId = getPushUpID()
        let sessionA = anySession(date: Date.distantPast, entries: [
            anyEntry(exercise: exerciseId)
        ])
        let sessionB = anySession(entries: [
            anyEntry(exercise: exerciseId)
        ])
        
        try await sut.addSessions([sessionA])
        try await sut.addSessions([sessionB])
        
        let retrieved = try await sut.retrieveSessions(by: .none)
        XCTAssertEqual(retrieved, [sessionA, sessionB])
    }
    
    func test_addSetsToEntry_ignoreSetsIfEntryDoesNotExist() async throws {
        let sut = try makeSUT()
        let sets = [anySet(order: 0), anySet(order: 1)]
        
        try await sut.addSets(sets, to: anyEntry())
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries).flatMap(\.sets)
        XCTAssertTrue(retrieved.isEmpty)
    }
    
    func test_addSetsToEntry_andRetrieveIt() async throws {
        let sut = try makeSUT()
        let entry = anyEntry(exercise: getPushUpID(), sets: [])
        let sets = [anySet(order: 0), anySet(order: 1)]
        
        try await sut.addEntry([entry], to: anySession())
        try await sut.addSets(sets, to: entry)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries).flatMap(\.sets)
        XCTAssertEqual(retrieved, sets)
    }
    
    func test_updateExercise_doesNotAffectStoredEntry() async throws {
        let sut = try makeSUT()
        let initialExercise = anyExercise(name: "Random exercise", category: .arms)
        let entry = anyEntry(exercise: initialExercise.id, sets: [anySet()])
        let randomEntry = anyEntry(createdAt: Date().adding(minutes: 2))
        let updatedExercise = anyExercise(id: initialExercise.id, name: "Updated Exercise", category: .abs)
        let query = QueryBuilder()
            .containsExercises([initialExercise.id])
            .build()
        
        try await sut.addCustomExercise(initialExercise)
        try await sut.addEntry([entry, randomEntry], to: anySession())
        try await sut.updateExercise(updatedExercise)
        
        let retrieved = try await sut.retrieveSessions(by: query).flatMap(\.entries)
        let firstEntry = try XCTUnwrap(retrieved.first)
        XCTAssertEqual(firstEntry.exerciseID, initialExercise.id)
    }
        
    func test_updateSession_changesSessionPropertiesWithoutChangingEntries() async throws {
        let sut = try makeSUT()
        let entry = anyEntry(exercise: getPushUpID(), sets: [anySet()])
        let session = anySession(date: Date(), entries: [entry])
        let newDate = Date().adding(days: -2)
        let newSession = anySession(id: session.id, date: newDate, entries: session.entries)
        
        try await sut.addSessions([session])
        try await sut.updateSession(newSession)
        
        let retrieved = try await sut.retrieveSessions(by: .none)
        XCTAssertEqual(retrieved, [newSession])
    }
    
    func test_updateEntry_changesEntryPropertiesWithoutChangingSessionAndSets() async throws {
        let sut = try makeSUT()
        let randomExercise = try await getRandomPresavedExerciseId()
        let entry = anyEntry(exercise: getPushUpID(), sets: [anySet()])
        let session = anySession(entries: [entry])
        let newEntry = anyEntry(id: entry.id, exercise: randomExercise, sets: entry.sets)
        
        try await sut.addSessions([session])
        try await sut.updateEntry(newEntry, within: session)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        XCTAssertEqual(retrieved, [newEntry])
    }
    
    func test_updateEntry_changesToExistedEntryWithSameExercise_throwCustomError() async throws {
        let sut = try makeSUT()
        let customExercise = anyExercise()
        let presavedEntry = anyEntry(exercise: customExercise.id, sets: [anySet()])
        let session = anySession()
        let updateEntry = anyEntry(exercise: getPushUpID(), sets: [anySet()], createdAt: Date().adding(seconds: 10))
        
        try await sut.addCustomExercise(customExercise)
        try await sut.addEntry([presavedEntry], to: session)
        try await sut.addEntry([updateEntry], to: session)
        
        let newEntry = anyEntry(id: updateEntry.id, exercise: customExercise.id, sets: updateEntry.sets, createdAt: updateEntry.createdAt, order: updateEntry.order)
        
        do {
            try await sut.updateEntry(newEntry, within: session)
            XCTFail("Expect to throw error due to duplicate exercise within same session but didn't")
        } catch {
            XCTAssertEqual(error as? WorkoutTrackError, .duplicateExerciseInSession)
        }
        
        let retrived = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        XCTAssertEqual(retrived, [presavedEntry, updateEntry])
    }
    
    func test_updateEntry_updatesAllOtherOrdersWhenUpdatingOrderValue() async throws {
        let sut = try makeSUT()
        let entryId = UUID()
        
        let entryA = anyEntry(order: 0)
        let entryB = anyEntry(order: 1)
        let entryC = anyEntry(id: entryId, order: 2)
        let session = anySession(entries: [entryA, entryB, entryC])
        
        let descriptor = QueryBuilder()
            .sort(by: .entryCustomOrder)
            .build()
        
        try await sut.addSessions([session])
        
        let updatedEntry = anyEntry(id: entryId, order: 0)
        
        try await sut.updateEntry(updatedEntry, within: session)
        // Entry A & Entry B should automatically adjust its order value
        let newEntryA = anyEntry(id: entryA.id, exercise: entryA.exerciseID, sets: entryA.sets, createdAt: entryA.createdAt, order: 1)
        let newEntryB = anyEntry(id: entryB.id, exercise: entryB.exerciseID, sets: entryB.sets, createdAt: entryB.createdAt, order: 2)
        
        let allEntries = try await sut.retrieveSessions(by: descriptor).flatMap(\.entries)
        XCTAssertEqual(allEntries.map(\.order), [0, 1, 2])
        XCTAssertEqual(allEntries, [updatedEntry, newEntryA, newEntryB])
    }
    
    func test_updateEntry_doesNotChangeOrderValueWhenThereIsOnlyOneEntry() async throws {
        let sut = try makeSUT()
        
        let entryId = UUID()
        let newExerciseId = UUID()
        
        let savedSession = anySession(entries: [
            anyEntry(id: entryId, exercise: UUID(), order: 0)
        ])
        
        try await sut.addSessions([savedSession])
        
        // Should not update the order when there's only one entry within a session
        let updatedEntry = anyEntry(id: entryId, exercise: newExerciseId, order: 1)
        try await sut.updateEntry(updatedEntry, within: savedSession)
        
        let result = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        let retrievedEntry = try XCTUnwrap(result.first)
        XCTAssertEqual(retrievedEntry.id, entryId)
        XCTAssertEqual(retrievedEntry.exerciseID, newExerciseId)
        XCTAssertEqual(retrievedEntry.order, 0)
    }
    
    func test_updateSet_changesSetPropertyWithoutChangingSessionAndEntry() async throws {
        let sut = try makeSUT()
        let oldSet = anySet(isFinished: false)
        let newSet = anySet(id: oldSet.id, isFinished: true)
        let entry = anyEntry(exercise: getPushUpID(), sets: [oldSet])
        let session = anySession(entries: [entry])
        
        try await sut.addEntry([entry], to: session)
        try await sut.updateSet(newSet, within: entry, and: session.id)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries).flatMap(\.sets)
        XCTAssertEqual(retrieved, [newSet])
    }
    
    func test_updateSet_updatesAllOthersOrderValueWhenUpdatingOrder() async throws {
        let sut = try makeSUT()
        let setId = UUID()
        
        let setA = anySet(order: 0)
        let setB = anySet(order: 1)
        let setC = anySet(id: setId, order: 2)
        let entry = anyEntry(sets: [
            setA, setB, setC
        ])
        let session = anySession(entries: [entry])
        
        try await sut.addSessions([session])
        
        let updatedSet = anySet(id: setId, order: 0)
        
        try await sut.updateSet(updatedSet, within: entry, and: session.id)
        // Set A & Set B should automatically adjust its order value
        let newSetA = anySet(id: setA.id, reps: setA.reps, weight: setA.weight, isFinished: setA.isFinished, order: 1)
        let newSetB = anySet(id: setB.id, reps: setB.reps, weight: setB.weight, isFinished: setB.isFinished, order: 2)
        
        let allSets = try await sut.retrieveSessions(by: .none).mapToAllSets()
        XCTAssertEqual(allSets.map(\.order), [0, 1, 2])
        XCTAssertEqual(allSets, [updatedSet, newSetA, newSetB])
    }
    
    func test_updateSet_doesNotChangeOrderValueWhenThereIsOnlyOneSet() async throws {
        let sut = try makeSUT()
        
        let setId = UUID()
        let entry = anyEntry(sets: [anySet(id: setId, isFinished: false, order: 0)])
        let savedSession = anySession(entries: [entry])
        
        try await sut.addSessions([savedSession])
        
        // Change the order to 1 (default is 0)
        let updatedSet = anySet(id: setId, isFinished: true, order: 1)
        
        try await sut.updateSet(updatedSet, within: entry, and: savedSession.id)
        // Should still be zero (zero-index based)
        let result = try await sut.retrieveSessions(by: .none).mapToAllSets()
        let retrievedSet = try XCTUnwrap(result.first)
        XCTAssertEqual(retrievedSet.id, setId)
        XCTAssertEqual(retrievedSet.isFinished, true)
        XCTAssertEqual(retrievedSet.order, 0)
    }
    
    func test_deleteExercise_deletesSubsequentWorkoutEntry() async throws {
        let sut = try makeSUT()
        let deletedExercise = anyExercise(name: "Random Exercise")
        let persistedExercise = anyExercise()
        let entry = [anyEntry(exercise: deletedExercise.id, sets: [anySet(), anySet(), anySet()]), anyEntry(exercise: deletedExercise.id)]
        let otherEntry = [anyEntry(exercise: persistedExercise.id)]
        
        try await sut.addCustomExercise(deletedExercise)
        try await sut.addCustomExercise(persistedExercise)
        try await sut.addEntry(otherEntry + entry, to: anySession())
        
        try await sut.deleteExercise(deletedExercise)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        XCTAssertEqual(retrieved, otherEntry)
        XCTAssertFalse(retrieved.map(\.id).contains(deletedExercise.id))
    }
    
    func test_deleteSession_removesSessionAndItsEntries() async throws {
        let sut = try makeSUT()
        let session = anySession()
        let entry = anyEntry(exercise: getPushUpID(), sets: [anySet()])
        
        try await sut.addEntry([entry], to: session)
        try await sut.deleteSession(session)
        
        let retrieved = try await sut.retrieveSessions(by: .none)
        XCTAssertTrue(retrieved.isEmpty)
    }
    
    func test_deleteEntry_removesEntryAndItsSets() async throws {
        let sut = try makeSUT()
        let deletedEntry = anyEntry(exercise: getPushUpID(), sets: [anySet(), anySet(), anySet(), anySet()])
        let randomA = try await getRandomPresavedExerciseId(), randomB = try await getRandomPresavedExerciseId()
        let otherEntry = [anyEntry(exercise: randomA), anyEntry(exercise: randomB)]
        
        try await sut.addEntry([deletedEntry] + otherEntry, to: anySession())
        try await sut.deleteEntry(deletedEntry)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        XCTAssertEqual(retrieved, otherEntry)
        XCTAssertTrue(retrieved.flatMap(\.sets).isEmpty)
    }
    
    func test_deleteSet_removesOnlyTargetedSet() async throws {
        let sut = try makeSUT()
        let deletedSet = anySet()
        let sets = [anySet(order: 0), anySet(order: 1)]
        let entry = anyEntry(exercise: getPushUpID(), sets: sets + [deletedSet])
        
        try await sut.addEntry([entry], to: anySession())
        try await sut.deleteSet(deletedSet)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries).flatMap(\.sets)
        
        XCTAssertEqual(retrieved, sets)
    }
       
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> WorkoutTrackService {
        let modelContainer = try makeTestModelContianer()
        let workoutStore = SwiftDataWorkoutSessionStore(modelContainer: modelContainer)
        let exerciseStore = SwiftDataExerciseStore(modelContainer: modelContainer)
        let exerciseSystem = DefaultExerciseSystem(
            loaders: [PresavedExercisesLoader(), exerciseStore],
            io: exerciseStore
        )
        let service = WorkoutTrackService(exercise: exerciseSystem, workoutTrack: workoutStore)
        trackForMemoryLeaks(service, file: file, line: line)
        return service
    }
    
    
    private func makeTestModelContianer() throws -> ModelContainer {
        let config = ModelConfiguration(
            "WorkoutTrackModel",
            isStoredInMemoryOnly: true
            )
        return try ModelContainer(for: ExerciseEntity.self, WorkoutEntry.self, WorkoutSession.self, WorkoutSet.self, configurations: config)
    }
    
    private func mergeEntriesToOne(_ entries: WorkoutEntryDTO...) -> WorkoutEntryDTO {
        let mergedSets = entries.flatMap(\.sets)
            .enumerated()
            .map { index, set in
                WorkoutSetDTO(
                    id: set.id,
                    reps: set.reps,
                    weight: set.weight,
                    isFinished: set.isFinished,
                    order: index)
            }
        let base = entries[0]
        return WorkoutEntryDTO(id: base.id, exerciseID: base.exerciseID, sets: mergedSets, createdAt: base.createdAt, order: base.order)
    }
    
    private func getPushUpID() -> UUID {
        UUID(uuidString: "5FBF70AE-30AC-F9A2-FF1F-D6A322FE1485")!
    }
    
    private func getRandomPresavedExerciseId() async throws -> UUID {
        return try await PresavedExercisesLoader().loadExercises(by: .all(sort: .none)).randomElement()!.id
    }
}

extension Array where Element == WorkoutSessionDTO {
    func mapToAllEntries() -> [WorkoutEntryDTO] {
        flatMap(\.entries)
    }
    
    func mapToAllSets() -> [WorkoutSetDTO] {
        flatMap(\.entries).flatMap(\.sets)
    }
}
