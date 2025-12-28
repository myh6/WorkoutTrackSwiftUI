//
//  WorkoutSessionStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/8.
//

import Foundation

public protocol WorkoutSessionStore {
    //MARK: - Insertion
    func insert(_ session: WorkoutSession) async throws
    func insert(_ entries: [WorkoutEntry], to session: WorkoutSession) async throws
    func insert(_ sets: [WorkoutSet], to entry: WorkoutEntry) async throws
    
    //MARK: - Retrieval
    func retrieve(query: SessionQueryDescriptor?) async throws -> [WorkoutSession]
    
    //MARK: - Deletion
    func delete(_ session: WorkoutSession) async throws
    func delete(_ entry: WorkoutEntry) async throws
    func delete(_ set: WorkoutSet) async throws
    
    //MARK: - Update
    func update(_ session: WorkoutSession) async throws
    func update(_ entry: WorkoutEntry) async throws
    func update(_ set: WorkoutSet) async throws
}

