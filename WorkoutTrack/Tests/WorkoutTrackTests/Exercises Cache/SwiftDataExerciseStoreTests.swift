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
        case .category(let ascending):
            return SortDescriptor(\.category, order: ascending ? .forward : .reverse)
        case .none:
            return nil
        }
    }
    
    var predicate: Predicate<ExerciseEntity>? {
        switch self {
        case .all:
            return #Predicate { _ in true }
        case .byID(let id, _):
            return #Predicate { $0.id == id }
        case .byName(let name, _):
            return #Predicate { $0.name == name }
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
        var descriptor = FetchDescriptor<ExerciseEntity>()
        if let predicate = query.predicate {
            descriptor.predicate = predicate
        }
        
        if let sort = query.sortDescriptor {
            descriptor.sortBy = [sort]
        } else {
            descriptor.sortBy = [SortDescriptor(\.name, order: .forward)]
        }
        
        return try modelContext.fetch(descriptor).toModels()
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
    
    func test_retrieve_all_noSorting_deliversAllExercisesSortedByNameInDefault() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()

        await batchInsert(exercisesInRandom, to: sut)

        let exercisesInOrder = exercisesInRandom.sortedByNameInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: nil))
    }
    
    func test_retrieve_all_sortedByName_deliversAllExercisesSortedByName() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()

        await batchInsert(exercisesInRandom, to: sut)

        let exercisesInOrder = exercisesInRandom.sortedByNameInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .name(ascending: true)))
    }
    
    func test_retrieve_all_sortedByName_deliversAllExercisesSortedByNameDescending() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeExercises(count: 5).shuffled()
        
        await batchInsert(exercisesInRandom, to: sut)
        
        let exercisesInOrder = exercisesInRandom.sortedByNameInDescendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .name(ascending: false)))
    }
    
    func test_retrieve_all_sortedByCategory_deliversAllExercisesSortedByCategory() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeMixedCategoryExercises().shuffled()
        
        await batchInsert(exercisesInRandom, to: sut)
        
        let exercisesInOrder = exercisesInRandom.sortedByCategoryInAscendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .category(ascending: true)))
    }
    
    func test_retrieve_all_sortedByCategory_deliversAllExercisesSortedByCategoryDescending() async throws {
        let sut = makeSUT()
        let exercisesInRandom = makeMixedCategoryExercises().shuffled()
        
        await batchInsert(exercisesInRandom, to: sut)
        
        let exercisesInOrder = exercisesInRandom.sortedByCategoryInDescendingOrder()
        
        try await expect(sut, toRetrievedWith: exercisesInOrder, with: .all(sort: .category(ascending: false)))
    }
    
    func test_retrieve_byId_deliversTheCorrectExercise() async throws {
        let sut = makeSUT()
        let id = UUID()
        let correctIdExercise = anyExercise(id: id)
        let allExercises = (makeExercises(count: 5) + [correctIdExercise]).shuffled()
        
        await batchInsert(allExercises, to: sut)
        
        try await expect(sut, toRetrievedWith: [correctIdExercise], with: .byID(id, sort: .none))
    }
    
    func test_retrieve_byName_deliversTheCorrectExercise() async throws {
        let sut = makeSUT()
        let name = "any name"
        let correctNameExercise = anyExercise(name: name)
        let allExercises = (makeExercises(count: 5) + [correctNameExercise]).shuffled()
        
        await batchInsert(allExercises, to: sut)
        
        try await expect(sut, toRetrievedWith: [correctNameExercise], with: .byName(name, sort: .none))
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
    
    private func makeExercises(count: Int, category: String = "any category") -> [CustomExercise] {
        (0..<count).map { index in
            CustomExercise(
                id: UUID(),
                name: "exercise \(index)",
                category: category
            )
        }
    }
    
    private func makeMixedCategoryExercises() -> [CustomExercise] {
        [
            CustomExercise(id: UUID(), name: "Bench Press", category: "Chest"),
            CustomExercise(id: UUID(), name: "Deadlift", category: "Back"),
            CustomExercise(id: UUID(), name: "Squat", category: "Legs"),
            CustomExercise(id: UUID(), name: "Curls", category: "Arms"),
            CustomExercise(id: UUID(), name: "Overhead Press", category: "Shoulders")
        ]
    }
}

private extension Array where Element == CustomExercise {
    func sortedByNameInAscendingOrder() -> [CustomExercise] {
        sorted { $0.name < $1.name }
    }
    
    func sortedByNameInDescendingOrder() -> [CustomExercise] {
        sorted { $0.name > $1.name }
    }
    
    func sortedByCategoryInAscendingOrder() -> [CustomExercise] {
        sorted { $0.category < $1.category }
    }
    
    func sortedByCategoryInDescendingOrder() -> [CustomExercise] {
        sorted { $0.category > $1.category }
    }
}
