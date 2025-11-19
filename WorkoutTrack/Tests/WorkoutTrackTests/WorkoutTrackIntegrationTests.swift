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
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> WorkoutTrackService {
        let modelContainer = try makeTestModelContianer()
        let workoutStore = SwiftDataWorkoutSessionStore(modelContainer: modelContainer)
        let exerciseStore = SwiftDataExerciseStore(modelContainer: modelContainer)
        let exerciseSystem = DefaultExerciseSystem(
            loaders: [PresavedExercisesLoader(), exerciseStore],
            inserter: exerciseStore,
            deleter: exerciseStore
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
    
    private func anyExercise(id: UUID = UUID(), name: String = "any name", category: BodyCategory = .abs) -> CustomExercise {
        return CustomExercise(id: id, name: name, category: category)
    }
}
