//
//  DisplayableExercise+Array.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/7.
//

@testable import WorkoutTrack

extension Array where Element == DisplayableExercise {
    func sortedInNameAscendingOrder() -> [DisplayableExercise] {
        sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    func sortedInNameDescendingOrder() -> [DisplayableExercise] {
        sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
    }
    
    func isInAscendingOrder() -> Bool {
        let res = self.sortedInNameAscendingOrder().map(\.id)
        let retrievedID = self.map(\.id)
        return res == retrievedID
    }
    
    func isInDescendingOrder() -> Bool {
        let res = self.sortedInNameDescendingOrder().map(\.id)
        let retrievedID = self.map(\.id)
        return res == retrievedID
    }
}
