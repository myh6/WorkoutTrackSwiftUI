//
//  XCTestCase+Exercise.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/12/21.
//

import Foundation
@testable import WorkoutTrack

extension WorkoutTrackService {
    func getRandomPresavedExerciseId() async throws -> UUID {
        return try await PresavedExercisesLoader().loadExercises(by: .all(sort: .none)).randomElement()!.id
    }
}
