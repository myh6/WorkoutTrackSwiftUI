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
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeInsertionSuccessfully()
        }
    }
    
    //MARK: - Load
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        store.completeRetrieval(with: retrievalError)
        
        do {
            _ = try sut.loadExercises()
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertEqual(error as NSError, retrievalError)
        }
    }
    
    func test_load_deliversRetrievedExercises() throws {
        let (sut, store) = makeSUT()
        let retrievedExercises: [CustomExercise] = [anyExercise(id: UUID()), anyExercise(id: UUID())]
        store.completeRetrievalSuccessfully(with: retrievedExercises)
        
        let loadedExercises = try sut.loadExercises()
        XCTAssertEqual(loadedExercises, retrievedExercises)
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
        
        // retriev
        func retrieve() throws -> [CustomExercise] {
            receivedMessage.append(.retrieve)
            return try retrievalResult?.get() ?? []
        }
        
        func completeRetrieval(with error: Error) {
            retrievalResult = .failure(error)
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
        func delete(_ exercise: CustomExercise) {
            receivedMessage.append(.delete(exercise))
        }
    }
    
    private func expect(_ sut: CustomSavedExercisesLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        action()
        
        do {
            try sut.save(anyExercise())
        } catch {
            XCTAssertEqual(error as NSError, expectedError, file: file, line: line)
        }
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    func anyExercise(id: UUID = UUID(), name: String = "any exercise", category: String = "any category") -> CustomExercise {
        CustomExercise(id: id, name: name, category: category)
    }
}
