//
//  EntryQuery.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/17.
//

import Foundation

enum EntryQuery {
    case all(sort: EntrySort?)
}

enum EntrySort {
    case byId(ascending: Bool)
}
