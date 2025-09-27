//
//  Exercise.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/6/25.
//

import Foundation

public struct Exercise: Equatable {
    public let nameKey: String
    public let categoryKey: String
    
    public init(nameKey: String, categoryKey: String) {
        self.nameKey = nameKey
        self.categoryKey = categoryKey
    }
}
