//
//  SessionQuery.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/17.
//

import Foundation

enum SessionQuery {
    case all(sort: SessionSort?)
    case sessionID(id: UUID)
}

enum SessionSort {
    case bySessionId(ascending: Bool)
    case byDate(ascending: Bool)
}
