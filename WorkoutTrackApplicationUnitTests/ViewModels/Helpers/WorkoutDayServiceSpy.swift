//
//  WorkoutDayServiceSpy.swift
//  WorkoutTrackApplicationUnitTests
//
//  Created by Min-Yang Huang on 2026/2/26.
//

import Foundation
import WorkoutTrack
@testable import WorkoutTrackSwiftUI

class WorkoutServiceSpy: WorkoutDayServicing {
    enum Message: Equatable {
        case retrieve,
             updateSet((session: UUID, entry: UUID, set: WorkoutSet)),
             requestName(UUID),
             deleteSet(WorkoutSet),
             addSet((weight: Double, reps: Int, entry: WorkoutEntry, sessionID: UUID)),
             updateEntry(WorkoutEntry)
            
        
        static func ==(_ lhs: Message, _ rhs: Message) -> Bool {
            switch (lhs, rhs) {
            case (.retrieve, .retrieve):
                return true
            case let (.updateSet(firstCtx), .updateSet(secondCtx)):
                return firstCtx.session == secondCtx.session && firstCtx.entry == secondCtx.entry && firstCtx.set.id == secondCtx.set.id // The rest of the properties need to be checked separately
            case let (.requestName(firstID), .requestName(secondID)):
                return firstID == secondID
            case let (.deleteSet(firstSet), .deleteSet(secondSet)):
                return firstSet == secondSet
            case let (.updateEntry(firstEntry), .updateEntry(secondEntry)):
                return firstEntry == secondEntry
            case let (.addSet(firstAddition), .addSet(secondAddition)):
                return firstAddition.weight == secondAddition.weight &&
                firstAddition.reps == secondAddition.reps &&
                firstAddition.entry == secondAddition.entry &&
                firstAddition.sessionID == secondAddition.sessionID
            default:
                return false
            }
        }
    }
    
    private(set) var receivedMessages = [Message]()
    private(set) var receivedQuery = [SessionQueryDescriptor]()

    private var stubbedRetrievalError: Error?
    private var shouldSuspend = false
    private var retrievalContinuation: CheckedContinuation<[WorkoutSession], Error>?
    
    private(set) var hasPendingRetrieval = false
    
    private var sessionsQueue: [[WorkoutSession]] = []
    func enqueueSession(_ batches: [[WorkoutSession]]) {
        sessionsQueue.append(contentsOf: batches)
    }
    
    func suspendNextRetrieval(_ val: Bool) {
        shouldSuspend = val
    }
    
    func completeRetrievalContinuation(with sessions: [WorkoutSession]) {
        hasPendingRetrieval = false
        retrievalContinuation?.resume(returning: sessions)
        retrievalContinuation = nil
    }
    
    func completeRetrievalContinuation(with error: Error) {
        hasPendingRetrieval = false
        retrievalContinuation?.resume(throwing: error)
        retrievalContinuation = nil
    }
    
    func stubRetrievalError(_ error: Error) {
        stubbedRetrievalError = error
    }
    
    func stubName(for id: UUID, name: String) {
        stubbedNames[id] = name
    }
    
    var stubbedNames: [UUID: String] = [:]
    func getExerciseName(from id: UUID) async throws -> String? {
        receivedMessages.append(.requestName(id))
        return stubbedNames[id]
    }
    
    func retrieveSessions(by query: SessionQueryDescriptor?) async throws -> [WorkoutTrack.WorkoutSession] {
        if let query {
            receivedQuery.append(query)
        }
        receivedMessages.append(.retrieve)
        if let stubbedRetrievalError {
            throw stubbedRetrievalError
        }
        
        if shouldSuspend {
            shouldSuspend = false
            return try await withCheckedThrowingContinuation { cont in
                self.retrievalContinuation = cont
                self.hasPendingRetrieval = true
            }
        } else {
            return sessionsQueue.isEmpty ? [] : sessionsQueue.removeFirst()
        }
    }
    
    private var updateError: Error?
    func stubUpdateError(_ error: Error) {
        updateError = error
    }
    
    func updateSet(_ set: WorkoutSet, within entry: WorkoutEntry, and session: UUID) async throws {
        receivedMessages.append(.updateSet((session, entry.id, set)))
        if let error = updateError { throw error }
    }
    
    private var deleteError: Error?
    func stubDeleteError(_ error: Error) {
        deleteError = error
    }
    func deleteSet(_ set: WorkoutSet) async throws {
        receivedMessages.append(.deleteSet(set))
        if let error = deleteError { throw error }
    }
    
    private var addingError: Error?
    func stubAddingError(_ error: Error) {
        addingError = error
    }
    func addSets(_ sets: [WorkoutSet], to entry: WorkoutEntry, within session: UUID) async throws {
        for set in sets {
            receivedMessages.append(.addSet((set.weight, set.reps, entry, session)))
        }
        if let error = addingError { throw error }
    }
    
    func stubUpdateEntryError(_ error: Error) {
        updateEntryError = error
    }
    
    private var updateEntryError: Error?
    func updateEntry(_ entry: WorkoutEntry, within session: WorkoutSession) async throws {
        receivedMessages.append(.updateEntry(entry))
        if let error = updateEntryError { throw error }
    }
}
