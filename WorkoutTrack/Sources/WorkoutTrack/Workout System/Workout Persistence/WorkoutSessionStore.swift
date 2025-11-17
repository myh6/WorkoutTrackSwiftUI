//
//  WorkoutSessionStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/11/8.
//

import Foundation

public protocol WorkoutSessionStore {
    //MARK: - Insertion
    func insert(_ session: WorkoutSessionDTO) async throws
    func insert(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) async throws
    func insert(_ sets: [WorkoutSetDTO], to entry: WorkoutEntryDTO) async throws
    
    //MARK: - Retrieval
    func retrieve(query: SessionQueryDescriptor?) async throws -> [WorkoutSessionDTO]
    
    //MARK: - Deletion
    func delete(_ session: WorkoutSessionDTO) async throws
    func delete(_ entry: WorkoutEntryDTO) async throws
    func delete(_ set: WorkoutSetDTO) async throws
    
    //MARK: - Update
    func update(_ session: WorkoutSessionDTO) async throws
    func update(_ entry: WorkoutEntryDTO, withinSession id: UUID) async throws
    func update(_ set: WorkoutSetDTO, withinEntry id: UUID) async throws
}

