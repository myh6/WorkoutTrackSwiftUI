//
//  Exercise.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 9/6/25.
//

import Foundation
import CryptoKit

public struct LocalizedExercise: Equatable {
    public let nameKey: String
    public let rawCategory: BodyCategory
    
    public init(nameKey: String, category: BodyCategory) {
        self.nameKey = nameKey
        self.rawCategory = category
    }
}

//MARK: - DisplayableExercise
extension LocalizedExercise: DisplayableExercise {
    public var id: UUID {
        let input = nameKey + "|" + rawCategory.rawValue
        let digest = SHA256.hash(data: Data(input.utf8))
        let bytes = Array(digest)
        let uuid = uuid_t(
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )
        return UUID(uuid: uuid)
    }

    public var name: String {
        NSLocalizedString(
            nameKey,
            tableName: "Exercises",
            bundle: ExercisesPresentationResources.bundle,
            comment: "Exercise name"
        )
    }

    public var category: String {
        rawCategory.localizedName
    }
    
    public var isCustom: Bool { false }
}
