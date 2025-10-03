//
//  SwiftDataExerciseStoreTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/9/29.
//

import XCTest
import WorkoutTrack
import SwiftData

@Model
final class ExerciseEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    
    init(id: UUID, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
}

extension ExerciseEntity {
    var model: CustomExercise {
        .init(id: id, name: name, category: category)
    }
}

extension Array where Element == ExerciseEntity {
    func toModels() -> [CustomExercise] {
        map(\.model)
    }
}

extension ExerciseQuery {
    private var sort: ExerciseSort? {
        switch self {
        case .all(let sort): return sort
        case .byID(_, let sort): return sort
        case .byName(_, let sort): return sort
        case .byCategory(_, let sort): return sort
        }
    }
    
    var sortDescriptor: SortDescriptor<ExerciseEntity>? {
        switch self.sort {
        case .name(let ascending):
            return SortDescriptor(\.name, order: ascending ? .forward : .reverse)
        case .category, .custom, .none:
            return nil
        }
    }
    
    var predicate: Predicate<ExerciseEntity>? {
        switch self {
        case .all:
            return #Predicate { _ in true }
        default:
            return nil
        }
    }
}

@ModelActor
final actor SwiftDataExerciseStore {
    func retrieve() throws -> [CustomExercise] {
        let descriptor = FetchDescriptor<ExerciseEntity>()
        return try modelContext.fetch(descriptor).toModels()
    }
    
    func insert(_ exercise: CustomExercise) {
        let entity = ExerciseEntity(id: exercise.id, name: exercise.name, category: exercise.category)
        modelContext.insert(entity)
    }
    
    func retrieve(by query: ExerciseQuery) throws -> [CustomExercise] {
        if let predicate = query.predicate, let sort = query.sortDescriptor {
            let descriptor = FetchDescriptor(predicate: predicate, sortBy: [sort])
            return try modelContext.fetch(descriptor).toModels()
        }
        return []
    }
}


final class SwiftDataExerciseStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveExercises: [])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyDatabase() async throws {
        let sut = makeSUT()
        
        try await expect(sut, toRetrieveExercisesTwice: [])
    }
    
    func test_retrieve_deliversFoundExercisesOnNonEmptyDatabase() async throws {
        let sut = makeSUT()
        let anyExercise = anyExercise()
        
        await sut.insert(anyExercise)
        
        try await expect(sut, toRetrieveExercises: [anyExercise])
    }
    
    func test_retrieve_all_sortedByName_deliversAllExercisesSortedByName() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()

        await batchInsert(exercisesInRandom, to: sut)

        let exercisesInOrder = exercisesInRandom.sortedByNameInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .name(ascending: true)))
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SwiftDataExerciseStore {
        let schema = Schema([ExerciseEntity.self])
        let sut = try! SwiftDataExerciseStore(modelContainer: ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: SwiftDataExerciseStore, toRetrieveExercises expected: [CustomExercise], file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieve()
        
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataExerciseStore, toRetrieveExercisesTwice expected: [CustomExercise], file: StaticString = #file, line: UInt = #line) async throws {
        try await expect(sut, toRetrieveExercises: expected, file: file, line: line)
        try await expect(sut, toRetrieveExercises: expected, file: file, line: line)
    }
    
    private func expect(_ sut: SwiftDataExerciseStore, toRetrievedWith expected: [CustomExercise], with query: ExerciseQuery, file: StaticString = #file, line: UInt = #line) async throws {
        let retrieved = try await sut.retrieve(by: query)
        XCTAssertEqual(expected, retrieved, file: file, line: line)
    }
    
    private func anyExercise(id: UUID = UUID(), name: String = "any exercise", category: String = "any category") -> CustomExercise {
        CustomExercise(id: id, name: name, category: category)
    }
    
    private func batchInsert(_ exercises: [CustomExercise], to store: SwiftDataExerciseStore) async {
        for exercise in exercises {
            await store.insert(exercise)
        }
    }
    
    func makeExercises(count: Int, category: String = "any category") -> [CustomExercise] {
        (0..<count).map { index in
            CustomExercise(
                id: UUID(),
                name: "exercise \(index)",
                category: category
            )
        }
    }
}

private extension Array where Element == CustomExercise {
    func sortedByNameInAscendingOrder() -> [CustomExercise] {
        sorted { $0.name < $1.name }
    }
}
