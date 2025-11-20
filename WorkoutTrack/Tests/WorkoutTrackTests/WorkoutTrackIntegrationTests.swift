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
}
