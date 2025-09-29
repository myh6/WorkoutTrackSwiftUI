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
    func test_save_requestsInsertionOfExercise() {
        let (sut, store) = makeSUT()
        let insertedExercise = anyExercise(id: UUID())
        
        try? sut.save(insertedExercise)
        
        XCTAssertEqual(store.receivedMessage, [.insert(insertedExercise)])
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteSaveWithError: insertionError) {
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteSaveWithError: nil) {
            store.completeInsertionSuccessfully()
        }
    }
    
    //MARK: - Load
    func test_load_requestsRetrievalOfExercises() {
        let (sut, store) = makeSUT()
        
        _ = try? sut.loadExercises()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteLoadWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoExerciseOnEmptyStore() throws {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteLoadWith: .success([])) {
            store.completeRetrievalSuccessfully(with: [])
        }
    }
    
    func test_load_hasNoSideEffectsOnEmptyStore() throws {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()
        
        _ = try? sut.loadExercises()
        _ = try? sut.loadExercises()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .retrieve])
    }
    
    func test_load_deliversRetrievedExercises() throws {
        let (sut, store) = makeSUT()
        let retrievedExercises: [CustomExercise] = [anyExercise(id: UUID()), anyExercise(id: UUID())]
        
        expect(sut, toCompleteLoadWith: .success(retrievedExercises)) {
            store.completeRetrievalSuccessfully(with: retrievedExercises)
        }
    }
    
    func test_load_hasNoSideEffectsOnNonEmptyStore() throws {
        let (sut, store) = makeSUT()
        let savedExercises = [anyExercise(), anyExercise()]
        store.completeRetrievalSuccessfully(with: savedExercises)
        
        expect(sut, toCompleteLoadWith: .success(savedExercises), when: {})
        expect(sut, toCompleteLoadWith: .success(savedExercises), when: {})
    }
    
    //MARK: - Remove
    func test_remove_requestsDeletionOfSpecifiedExercise() {
        let (sut, store) = makeSUT()
        let exerciseToDelete = anyExercise()
        
        try? sut.remove(exerciseToDelete)
        
        XCTAssertEqual(store.receivedMessage, [.delete(exerciseToDelete)])
    }
    
    func test_remove_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        do {
            try sut.remove(anyExercise())
            XCTFail("Expected to fail")
        } catch {
            XCTAssertEqual(error as NSError, deletionError)
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
        func retrieve() throws -> [CustomExercise] {
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
        func insert(_ exercise: CustomExercise) throws {
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
        func delete(_ exercise: CustomExercise) throws {
            receivedMessage.append(.delete(exercise))
            try deletionResult?.get()
        }
        
        func completeDeletion(with error: Error) {
            deletionResult = .failure(error)
        }
    }
    
    private func expect(_ sut: CustomSavedExercisesLoader, toCompleteSaveWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        action()
        
        do {
            try sut.save(anyExercise())
        } catch {
            XCTAssertEqual(error as NSError, expectedError, file: file, line: line)
        }
    }
    
    private func expect(_ sut: CustomSavedExercisesLoader, toCompleteLoadWith expectedResult: Result<[CustomExercise], Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        action()
        
        let receivedResult = Result { try sut.loadExercises() }
        switch (expectedResult, receivedResult) {
        case (.success(let expectedValue), .success(let receivedValue)):
            XCTAssertEqual(expectedValue, receivedValue, file: file, line: line)
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
