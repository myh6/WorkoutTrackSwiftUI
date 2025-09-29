//
//  LoadExerciseFromCacheUseCaseTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/11/25.
//

import XCTest
import WorkoutTrack

final class LoadExerciseFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestsInsertionOfExercise() {
        let (sut, store) = makeSUT()
        let insertedExercise = anyExercise(id: UUID())
        
        try? sut.save(insertedExercise)
        
        XCTAssertEqual(store.receivedMessage, [.insert(insertedExercise)])
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
        
        func retrieve() -> [CustomExercise] {
            receivedMessage.append(.retrieve)
            return []
        }
        
        func insert(_ exercise: CustomExercise) {
            receivedMessage.append(.insert(exercise))
        }
        
        func delete(_ exercise: CustomExercise) {
            receivedMessage.append(.delete(exercise))
        }
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    func anyExercise(id: UUID = UUID(), name: String = "any exercise", category: String = "any category") -> CustomExercise {
        CustomExercise(id: id, name: name, category: category)
    }
}
