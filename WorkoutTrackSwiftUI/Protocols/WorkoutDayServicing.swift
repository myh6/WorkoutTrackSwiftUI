//
//  WorkoutDayServicing.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/24.
//

import Foundation
import WorkoutTrack

protocol WorkoutDayServicing {
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutSession]
    func getExerciseName(from id: UUID) async throws -> String?
    func deleteSet(_ set: WorkoutSet) async throws
    func updateSet(_ set: WorkoutSet, within entry: WorkoutEntry, and session: UUID) async throws
}

