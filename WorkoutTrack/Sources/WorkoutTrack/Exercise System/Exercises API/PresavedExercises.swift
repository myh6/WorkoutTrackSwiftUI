//
//  PresavedExercises.swift
//  WorkoutTrack
//
//  Created by Assistant on 2025/10/05.
//

import Foundation

public enum BodyCategory: String, CaseIterable {
    // Note: These values should not be changed as we use the raw value (String) of these cases as the value for category in our database.
    case abs
    case arms
    case back
    case chest
    case glutes
    case legs
    case shoulder
    case other
}

enum PresavedExercises {
    static let grouped: [(category: BodyCategory, exercises: [LocalizedExercise])] =
        BodyCategory.allCases.map { ($0, $0.exercises) }

    /// A flattened list of all presaved exercises.
    static let all: [LocalizedExercise] = grouped.flatMap { $0.exercises }
}

extension BodyCategory {
    static func fromCategoryKey(_ key: String) -> BodyCategory {
        allCases.first(where: { $0.categoryKey == key }) ?? .other
    }
}

extension BodyCategory {
    private var categoryKey: String { "exercise.category.\(rawValue)" }
    
    var localizedName: String {
        NSLocalizedString(
            categoryKey,
            tableName: "Exercises",
            bundle: ExercisesPresentationResources.bundle,
            comment: "Exercise category"
        )
    }

    var exercises: [LocalizedExercise] {
        switch self {
        case .abs:
            return [
                .init(nameKey: "exercise.name.basic_crunch", category: self),
                .init(nameKey: "exercise.name.crunch_hands_to_knees", category: self),
                .init(nameKey: "exercise.name.elevated_heel_touch", category: self),
                .init(nameKey: "exercise.name.flutter_kick", category: self),
                .init(nameKey: "exercise.name.front_scissors", category: self),
                .init(nameKey: "exercise.name.knee_to_elbow_sit_up", category: self),
                .init(nameKey: "exercise.name.leg_lowers", category: self),
                .init(nameKey: "exercise.name.machine_crunch", category: self),
                .init(nameKey: "exercise.name.plank", category: self),
                .init(nameKey: "exercise.name.reverse_crunch", category: self),
                .init(nameKey: "exercise.name.russian_twist", category: self),
                .init(nameKey: "exercise.name.side_plank", category: self),
                .init(nameKey: "exercise.name.v_sit", category: self),
                .init(nameKey: "exercise.name.windshield_wiper", category: self)
            ]

        case .arms:
            return [
                .init(nameKey: "exercise.name.barbell_curl", category: self),
                .init(nameKey: "exercise.name.barbell_skull_crusher", category: self),
                .init(nameKey: "exercise.name.cable_curl", category: self),
                .init(nameKey: "exercise.name.cable_overhead_extension", category: self),
                .init(nameKey: "exercise.name.cable_rope_pushdown", category: self),
                .init(nameKey: "exercise.name.concentration_curl", category: self),
                .init(nameKey: "exercise.name.decline_tricep_extension", category: self),
                .init(nameKey: "exercise.name.dip", category: self),
                .init(nameKey: "exercise.name.dumbbell_decline_curl", category: self),
                .init(nameKey: "exercise.name.dumbbell_hammer_curl", category: self),
                .init(nameKey: "exercise.name.dumbbell_incline_curl", category: self),
                .init(nameKey: "exercise.name.dumbbell_kickback", category: self),
                .init(nameKey: "exercise.name.dumbbell_overhead_extension", category: self),
                .init(nameKey: "exercise.name.dumbbell_skull_crusher", category: self),
                .init(nameKey: "exercise.name.incline_triceps_extension", category: self),
                .init(nameKey: "exercise.name.lying_tricep_extension", category: self),
                .init(nameKey: "exercise.name.machine_bicep_curl", category: self),
                .init(nameKey: "exercise.name.machine_seated_dip", category: self),
                .init(nameKey: "exercise.name.overhead_cable_extension", category: self),
                .init(nameKey: "exercise.name.preacher_curl", category: self),
                .init(nameKey: "exercise.name.spider_curl", category: self)
            ]

        case .back:
            return [
                .init(nameKey: "exercise.name.back_extension", category: self),
                .init(nameKey: "exercise.name.barbell_good_morning", category: self),
                .init(nameKey: "exercise.name.barbell_row", category: self),
                .init(nameKey: "exercise.name.cable_one_arm_lat_pull", category: self),
                .init(nameKey: "exercise.name.cable_one_arm_pulldown", category: self),
                .init(nameKey: "exercise.name.cable_rope_pullover", category: self),
                .init(nameKey: "exercise.name.chin_up", category: self),
                .init(nameKey: "exercise.name.close_grip_pull", category: self),
                .init(nameKey: "exercise.name.dumbbell_good_morning", category: self),
                .init(nameKey: "exercise.name.dumbbell_row", category: self),
                .init(nameKey: "exercise.name.lat_pulldown", category: self),
                .init(nameKey: "exercise.name.machine_lat_pulldown", category: self),
                .init(nameKey: "exercise.name.machine_row", category: self),
                .init(nameKey: "exercise.name.pull_up", category: self),
                .init(nameKey: "exercise.name.reverse_grip_pull", category: self),
                .init(nameKey: "exercise.name.seated_cable_row", category: self),
                .init(nameKey: "exercise.name.t_bar_row", category: self),
                .init(nameKey: "exercise.name.wide_grip_pull", category: self)
            ]

        case .chest:
            return [
                .init(nameKey: "exercise.name.barbell_bench_press", category: self),
                .init(nameKey: "exercise.name.barbell_decline_bench_press", category: self),
                .init(nameKey: "exercise.name.barbell_incline_bench_press", category: self),
                .init(nameKey: "exercise.name.cable_chest_press", category: self),
                .init(nameKey: "exercise.name.cable_crossover", category: self),
                .init(nameKey: "exercise.name.dumbbell_bench_press", category: self),
                .init(nameKey: "exercise.name.dumbbell_decline_bench_press", category: self),
                .init(nameKey: "exercise.name.dumbbell_decline_fly", category: self),
                .init(nameKey: "exercise.name.dumbbell_incline_bench_press", category: self),
                .init(nameKey: "exercise.name.dumbbell_incline_fly", category: self),
                .init(nameKey: "exercise.name.dumbbell_pullover", category: self),
                .init(nameKey: "exercise.name.low_cable_crossover", category: self),
                .init(nameKey: "exercise.name.machine_chest_press", category: self),
                .init(nameKey: "exercise.name.pec_deck", category: self),
                .init(nameKey: "exercise.name.push_up", category: self),
                .init(nameKey: "exercise.name.single_arm_dumbbell_press", category: self)
            ]

        case .glutes:
            return [
                .init(nameKey: "exercise.name.cable_donkey_kick", category: self),
                .init(nameKey: "exercise.name.glute_bridge", category: self),
                .init(nameKey: "exercise.name.hip_thrust", category: self),
                .init(nameKey: "exercise.name.kettlebell_swing", category: self),
                .init(nameKey: "exercise.name.machine_donkey_kick", category: self)
            ]

        case .legs:
            return [
                .init(nameKey: "exercise.name.back_squat", category: self),
                .init(nameKey: "exercise.name.calf_raise", category: self),
                .init(nameKey: "exercise.name.cable_lateral_leg_raise", category: self),
                .init(nameKey: "exercise.name.dumbbell_step_up", category: self),
                .init(nameKey: "exercise.name.front_squat", category: self),
                .init(nameKey: "exercise.name.lateral_lunge", category: self),
                .init(nameKey: "exercise.name.leg_extension", category: self),
                .init(nameKey: "exercise.name.leg_press", category: self),
                .init(nameKey: "exercise.name.pistol_squat", category: self),
                .init(nameKey: "exercise.name.reverse_lunge", category: self),
                .init(nameKey: "exercise.name.romanian_deadlift", category: self),
                .init(nameKey: "exercise.name.single_leg_rdl", category: self),
                .init(nameKey: "exercise.name.sumo_deadlift", category: self),
                .init(nameKey: "exercise.name.sumo_squat", category: self),
                .init(nameKey: "exercise.name.traditional_deadlift", category: self),
                .init(nameKey: "exercise.name.walking_lunge", category: self),
                .init(nameKey: "exercise.name.side_leg_raise", category: self)
            ]

        case .shoulder:
            return [
                .init(nameKey: "exercise.name.barbell_shrug", category: self),
                .init(nameKey: "exercise.name.barbell_upright_row", category: self),
                .init(nameKey: "exercise.name.cable_face_pull", category: self),
                .init(nameKey: "exercise.name.cable_one_arm_lateral_raise", category: self),
                .init(nameKey: "exercise.name.cable_rear_delt_fly", category: self),
                .init(nameKey: "exercise.name.cable_shrug", category: self),
                .init(nameKey: "exercise.name.cable_upright_row", category: self),
                .init(nameKey: "exercise.name.dumbbell_front_raise", category: self),
                .init(nameKey: "exercise.name.dumbbell_lateral_raise", category: self),
                .init(nameKey: "exercise.name.dumbbell_reverse_fly", category: self),
                .init(nameKey: "exercise.name.dumbbell_shoulder_press", category: self),
                .init(nameKey: "exercise.name.dumbbell_shrug", category: self),
                .init(nameKey: "exercise.name.dumbbell_upright_row", category: self),
                .init(nameKey: "exercise.name.landmine_press", category: self),
                .init(nameKey: "exercise.name.machine_lateral_raise", category: self),
                .init(nameKey: "exercise.name.machine_reverse_fly", category: self),
                .init(nameKey: "exercise.name.machine_shoulder_press", category: self),
                .init(nameKey: "exercise.name.military_press", category: self),
                .init(nameKey: "exercise.name.plate_front_raise", category: self)
            ]
        case .other:
            return []
        }
    }
}
