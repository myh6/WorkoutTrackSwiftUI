//
//  ExerciseEntity.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/3.
//

import Foundation
import SwiftData

@Model
final class ExerciseEntity {
    @Attribute(.unique) var id: UUID
    var name: String {
        didSet {
            lowercasedName = name.lowercased()
        }
    }
    
    /// Store ``BodyCategory`` raw value
    var category: String {
        didSet {
            lowercasedCategory = category.lowercased()
        }
    }
    
    var lowercasedName: String
    var lowercasedCategory: String
    
    init(id: UUID, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
        self.lowercasedName = name.lowercased()
        self.lowercasedCategory = category.lowercased()
    }
}

extension ExerciseEntity {
    var model: CustomExercise {
        .init(id: id, name: name, category: BodyCategory(rawValue: category) ?? .other)
    }
}

extension Array where Element == ExerciseEntity {
    func toModels() -> [CustomExercise] {
        map(\.model)
    }
}

extension ExerciseQuery {
    private var sort: ExerciseSort? {
        switch self {
        case .all(let sort): return sort
        case .byID(_): return nil
        case .byName(_, let sort): return sort
        case .byCategory(_, let sort): return sort
        }
    }
    
    var sortDescriptor: SortDescriptor<ExerciseEntity>? {
        switch self.sort {
        case .name(let ascending):
            return SortDescriptor(\.name, order: ascending ? .forward : .reverse)
        case .category(let ascending):
            return SortDescriptor(\.category, order: ascending ? .forward : .reverse)
        case .none:
            return nil
        }
    }
    
    var predicate: Predicate<ExerciseEntity>? {
        switch self {
        case .all:
            return #Predicate { _ in true }
        case .byID(let id):
            return #Predicate { $0.id == id }
        case .byName(let name, _):
            return #Predicate { $0.lowercasedName.contains(name) }
        case .byCategory(let category, _):
            let lowercasedRetrieved = category.rawValue.lowercased()
            return #Predicate { $0.lowercasedCategory == lowercasedRetrieved }
        }
    }
}
