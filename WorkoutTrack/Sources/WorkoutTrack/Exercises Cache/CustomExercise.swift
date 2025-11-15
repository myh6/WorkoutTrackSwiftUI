//
//  CustomExercise.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/9/29.
//

import Foundation

// DTO (Data Transfer Object) for SwiftData's ExerciseEntity
public struct CustomExercise: Equatable {
    public let id: UUID
    public let name: String
    public var rawCategory: BodyCategory
    
    public init(id: UUID, name: String, category: BodyCategory) {
        self.id = id
        self.name = name
        self.rawCategory = category
    }
}

extension CustomExercise: DisplayableExercise {
    public var isCustom: Bool { true }
    
    public var category: String {
        rawCategory.localizedName
    }
}
