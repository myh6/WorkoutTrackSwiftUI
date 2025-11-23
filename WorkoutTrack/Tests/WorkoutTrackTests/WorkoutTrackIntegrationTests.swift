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
        let oldEntries = [anyEntry()]
        let newEntries = [anyEntry(), anyEntry()]
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
    
    private func getPushUpID() -> UUID {
        UUID(uuidString: "5FBF70AE-30AC-F9A2-FF1F-D6A322FE1485")!
    }
    
    private func getRandomPresavedExerciseId() async throws -> UUID {
        return try await PresavedExercisesLoader().loadExercises(by: .all(sort: .none)).randomElement()!.id
    }
}
