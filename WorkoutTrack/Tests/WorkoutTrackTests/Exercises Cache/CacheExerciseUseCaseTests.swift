//
//  LoadExerciseFromCacheUseCaseTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import XCTest
import WorkoutTrack

final class CacheExerciseUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    //MARK: - Save
    func test_save_requestsInsertionOfExercise() async throws {
        let (sut, store) = makeSUT()
        let insertedExercise = anyExercise(id: UUID())
        
        try await sut.save(insertedExercise)
        
        XCTAssertEqual(store.receivedMessage, [.insert(insertedExercise)])
    }
    
    func test_save_failsOnInsertionError() async {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        await expect(sut, toCompleteSaveWithError: insertionError) {
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulInsertion() async {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteSaveWithError: nil) {
            store.completeInsertionSuccessfully()
        }
    }
    
    //MARK: - Load
    func test_load_requestsRetrievalOfExercises() async throws {
        let (sut, store) = makeSUT()
        
        _ = try await sut.loadExercises()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() async {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        await expect(sut, toCompleteLoadWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoExerciseOnEmptyStore() async throws {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteLoadWith: .success([])) {
            store.completeRetrievalSuccessfully(with: [])
        }
    }
    
    func test_load_hasNoSideEffectsOnEmptyStore() async throws {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()
        
        _ = try await sut.loadExercises()
        _ = try await sut.loadExercises()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .retrieve])
    }
    
    func test_load_deliversRetrievedExercises() async throws {
        let (sut, store) = makeSUT()
        let retrievedExercises: [CustomExercise] = [anyExercise(id: UUID()), anyExercise(id: UUID())]
        
        await expect(sut, toCompleteLoadWith: .success(retrievedExercises)) {
            store.completeRetrievalSuccessfully(with: retrievedExercises)
        }
    }
    
    func test_load_hasNoSideEffectsOnNonEmptyStore() async throws {
        let (sut, store) = makeSUT()
        let savedExercises = [anyExercise(), anyExercise()]
        store.completeRetrievalSuccessfully(with: savedExercises)
        
        await expect(sut, toCompleteLoadWith: .success(savedExercises), when: {})
        await expect(sut, toCompleteLoadWith: .success(savedExercises), when: {})
    }
    
    //MARK: - Remove
    func test_remove_requestsDeletionOfSpecifiedExercise() async throws {
        let (sut, store) = makeSUT()
        let exerciseToDelete = anyExercise()
        
        try await sut.remove(exerciseToDelete)
        
        XCTAssertEqual(store.receivedMessage, [.delete(exerciseToDelete)])
    }
    
    func test_remove_failsOnDeletionError() async {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        await expect(sut, toCompleteRemoveWith: .failure(deletionError)) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_remove_succeedsOnSuccessfulDeletion() async throws {
        let (sut, store) = makeSUT()
        
        await expect(sut, toCompleteRemoveWith: .success(())) {
            store.completeDeletionSuccessfully()
        }
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CustomSavedExercisesLoader, store: ExerciseStoreSpy) {
        let store = ExerciseStoreSpy()
        let sut = CustomSavedExercisesLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class ExerciseStoreSpy: ExerciseStore {
        enum Message: Equatable {
            case retrieve
            case insert(CustomExercise)
            case delete(CustomExercise)
        }
        
        private(set) var receivedMessage = [Message]()
        
        private var insertionResult: Result<Void, Error>?
        private var retrievalResult: Result<[CustomExercise], Error>?
        private var deletionResult: Result<Void, Error>?
        
        // retriev
        func retrieve() async throws -> [CustomExercise] {
            receivedMessage.append(.retrieve)
            return try retrievalResult?.get() ?? []
        }
        
        func completeRetrieval(with error: Error) {
            retrievalResult = .failure(error)
        }
        
        func completeRetrievalWithEmptyCache() {
            retrievalResult = .success([])
        }
        
        func completeRetrievalSuccessfully(with exercises: [CustomExercise]) {
            retrievalResult = .success(exercises)
        }
        
        // insert
        func insert(_ exercise: CustomExercise) async throws {
            receivedMessage.append(.insert(exercise))
            try insertionResult?.get()
        }
        
        func completeInsertion(with error: Error) {
            insertionResult = .failure(error)
        }
        
        func completeInsertionSuccessfully() {
            insertionResult = .success(())
        }
        
        // delete
        func delete(_ exercise: CustomExercise) async throws {
            receivedMessage.append(.delete(exercise))
            try deletionResult?.get()
        }
        
        func completeDeletion(with error: Error) {
            deletionResult = .failure(error)
        }
        
        func completeDeletionSuccessfully() {
            deletionResult = .success(())
        }
    }
    
    private func expect(_ sut: CustomSavedExercisesLoader, toCompleteSaveWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) async {
        
        action()
        
        do {
            try await sut.save(anyExercise())
        } catch {
            XCTAssertEqual(error as NSError, expectedError, file: file, line: line)
        }
    }
    
    private func expect(_ sut: CustomSavedExercisesLoader, toCompleteLoadWith expectedResult: Result<[CustomExercise], Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) async {
        
        action()
        
        let receivedResult: Result<[CustomExercise], Error>
        do {
            let value = try await sut.loadExercises()
            receivedResult = .success(value)
        } catch {
            receivedResult = .failure(error)
        }
        
        switch (expectedResult, receivedResult) {
        case (.success(let expectedValue), .success(let receivedValue)):
            XCTAssertEqual(expectedValue, receivedValue, file: file, line: line)
        case (.failure(let expectedError), .failure(let receivedError)):
            XCTAssertEqual(expectedError as NSError, receivedError as NSError)
        default:
            XCTFail("Expected to get \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func expect(_ sut: CustomSavedExercisesLoader, toCompleteRemoveWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) async {
        
        action()
        
        let receivedResult: Result<Void, Error>
        do {
            try await sut.remove(anyExercise())
            receivedResult = .success(())
        } catch {
            receivedResult = .failure(error)
        }
        
        switch (expectedResult, receivedResult) {
        case (.success, .success):
            break
        case (.failure(let expectedError), .failure(let receivedError)):
            XCTAssertEqual(expectedError as NSError, receivedError as NSError)
        default:
            XCTFail("Expected to get \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    func anyExercise(id: UUID = UUID(), name: String = "any exercise", category: String = "any category") -> CustomExercise {
        CustomExercise(id: id, name: name, category: category)
    }
}

