//
//  WorkoutTrackIntegrationTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/17.
//

import XCTest
@testable import WorkoutTrack
import SwiftData

class WorkoutTrackService {
    private let exercise: ExerciseSystem
    private let workoutTrack: WorkoutSessionStore
    
    init(exercise: ExerciseSystem, workoutTrack: WorkoutSessionStore) {
        self.exercise = exercise
        self.workoutTrack = workoutTrack
    }
}

extension WorkoutTrackService {
    func addCustomExercise(_ exercise: CustomExercise) async throws {
        try await self.exercise.addExercise(exercise)
    }
}

extension WorkoutTrackService {
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSessionDTO] {
        try await self.workoutTrack.retrieve(query: query)
    }
    
    func addEntry(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws {
        try await self.workoutTrack.insert(entries, to: session)
    }
}

final class WorkoutTrackIntegrationTests: XCTestCase {
    private var service: WorkoutTrackService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        deleteStoreArtifacts()
        let storeURL = testSpecificStoreURL()
        let modelContainer = try makeTestModelContianer(storeURL: storeURL)
        let workoutStore = SwiftDataWorkoutSessionStore(modelContainer: modelContainer)
        let exerciseStore = SwiftDataExerciseStore(modelContainer: modelContainer)
        let exerciseSystem = DefaultExerciseSystem(loaders: [PresavedExercisesLoader(), exerciseStore], inserter: exerciseStore, deleter: exerciseStore)
        service = WorkoutTrackService(exercise: exerciseSystem, workoutTrack: workoutStore)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        deleteStoreArtifacts()
    }
    
    //MARK: - Test Cases
    func test_addCustomExercise_andUseInWorkoutSession() async throws {
        let exercise = anyExercise(name: "Zercher Squat", category: .legs)
        let entry = anyEntry(exercise: exercise.id, sets: [anySet()])
        
        try await service.addCustomExercise(exercise)
        try await service.addEntry([entry], to: anySession())
        
        let retrieved = try await service.retrieveSessions(by: nil).flatMap(\.entries)
        XCTAssertEqual(retrieved.count, 1)
        let retrievedEntry = try XCTUnwrap(retrieved.first)
        XCTAssertEqual(retrievedEntry.exerciseID, exercise.id)
    }
    
    //MARK: - Helpers
    private func makeTestModelContianer(storeURL: URL) throws -> ModelContainer {
        let config = ModelConfiguration(
            "WorkoutTrackModel",
            url: storeURL,
            allowsSave: true)
        return try ModelContainer(for: ExerciseEntity.self, WorkoutEntry.self, WorkoutSession.self, WorkoutSet.self, configurations: config)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deleteStoreArtifacts() {
        let url = testSpecificStoreURL()
        try? FileManager.default.removeItem(at: url)
    }
    
    private func anyExercise(id: UUID = UUID(), name: String = "any name", category: BodyCategory = .abs) -> CustomExercise {
        return CustomExercise(id: id, name: name, category: category)
    }
}
