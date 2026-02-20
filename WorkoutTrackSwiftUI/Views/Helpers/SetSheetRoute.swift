//
//  SetSheetRoute.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/2/20.
//

import Foundation

enum SetSheetRoute: Identifiable {
    case add(entryID: UUID)
    case update(entryID: UUID, set: SetRow)
    
    var id: UUID {
        switch self {
        case .add(let entryID):
            return entryID
        case .update(_, let set):
            return set.id
        }
    }
}
