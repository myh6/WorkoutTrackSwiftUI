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
    
    func test_addSessions_andRetrievIt() async throws {
        let sut = try makeSUT()
        let sessions = [anySession(), anySession(), anySession(), anySession()]
        
        try await sut.addSessions(sessions)
        
        let retrieved = try await sut.retrieveSessions(by: .none)
        XCTAssertEqual(retrieved, sessions)
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
        let otherEntry = [anyEntry(exercise: persistedExercise.id), anyEntry(exercise: persistedExercise.id), anyEntry(exercise: persistedExercise.id)]
        
        try await sut.addCustomExercise(deletedExercise)
        try await sut.addCustomExercise(persistedExercise)
        try await sut.addEntry(otherEntry + entry, to: anySession())
        
        try await sut.deleteExercise(deletedExercise)
        
        let retrieved = try await sut.retrieveSessions(by: .none).flatMap(\.entries)
        XCTAssertEqual(retrieved.count, 3)
        XCTAssertFalse(retrieved.map(\.id).contains(deletedExercise.id))
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
}
