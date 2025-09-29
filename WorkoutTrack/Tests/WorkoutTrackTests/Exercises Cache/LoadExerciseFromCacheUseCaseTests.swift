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
        let store = ExerciseStoreSpy()
        let _ = CustomSavedExercisesLoader(store: store)
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    //MARK: - Helpers
    private class ExerciseStoreSpy: ExerciseStore {
        enum Message {
            case retrieve
        }
        
        private(set) var receivedMessage = [Message]()
        
        func retrieve() -> [CustomExercise] {
            receivedMessage.append(.retrieve)
            return []
        }
    }

}
