//
//  QueryBuilder.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/19.
//

import Foundation

public struct SessionQueryDescriptor {
    public let sessionId: UUID?
    public let dateRange: ClosedRange<Date>?
    public let containExercises: [UUID]?
    public let sortBy: [QuerySort]?
    public let postProcessing: [PostProcessing]?
}

public enum QuerySort: Equatable {
    case byId(ascending: Bool)
    case byDate(ascending: Bool)
    case entryCustomOrder
}

public struct QueryBuilder {
    private var sessionId: UUID?
    private var dateRange: ClosedRange<Date>?
    private var containExercises: [UUID]?
    private var sortBy: [QuerySort]?
    private var postProcess: [PostProcessing]?
    
    public init() {}
    
    public func filterSession(_ id: UUID) -> Self {
        var copy = self
        copy.sessionId = id
        return copy
    }
    
    public func filterDateRange(_ range: ClosedRange<Date>) -> Self {
        var copy = self
        copy.dateRange = range
        return copy
    }
    
    public func sort(by sort: QuerySort) -> Self {
        var copy = self
        if sort == .entryCustomOrder {
            copy.postProcess = createArrayIfNeeded(postProcess) + [.sortByEntryCustomOrder]
        } else {
            copy.sortBy = createArrayIfNeeded(sortBy) + [sort]
        }
        return copy
    }
    
    public func containsExercises(_ ids: [UUID]) -> Self {
        var copy = self
        copy.containExercises = ids
        return copy
    }
    
    public func onlyIncludFinishedSets() -> Self {
        var copy = self
        copy.postProcess = createArrayIfNeeded(postProcess) + [.onlyIncludFinishedSets]
        return copy
    }
    
    public func onlyIncludExercises(_ ids: [UUID]) -> Self {
        var copy = self
        copy.postProcess = createArrayIfNeeded(postProcess) + [.onlyIncludeExercises(ids)]
        return copy
    }
    
    public func limitToFirst(_ count: Int) -> Self {
        var copy = self
        copy.postProcess = createArrayIfNeeded(postProcess) + [.limitToFirst(count)]
        return copy
    }
    
    public func build() -> SessionQueryDescriptor {
        return SessionQueryDescriptor(
            sessionId: sessionId,
            dateRange: dateRange,
            containExercises: containExercises,
            sortBy: sortBy,
            postProcessing: postProcess
        )
    }
    
    private func createArrayIfNeeded<T: Any>(_ value: [T]?) -> [T] {
        guard let value else { return [] }
        return value
    }
}
