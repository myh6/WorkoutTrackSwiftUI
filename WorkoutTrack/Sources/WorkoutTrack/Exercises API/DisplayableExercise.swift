//
//  DisplayableExercise.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/9/28.
//

import Foundation

public protocol DisplayableExercise {
    var id: UUID { get }
    var name: String { get }
    var category: String { get }
    var isCustom: Bool { get }
}
