//
//  PresavedExercises.swift
//  WorkoutTrack
//
//  Created by Assistant on 2025/10/05.
//

import Foundation

enum ExerciseCategory: String, CaseIterable {
    case abs
    case arms
    case back
    case chest
    case glutes
    case legs
    case shoulder
}

enum PresavedExercises {
    static let grouped: [(category: ExerciseCategory, exercises: [LocalizedExercise])] =
        ExerciseCategory.allCases.map { ($0, $0.exercises) }

    /// A flattened list of all presaved exercises.
    static let all: [LocalizedExercise] = grouped.flatMap { $0.exercises }
}

private extension ExerciseCategory {
    var categoryKey: String { "exercise.category.\(rawValue)" }

    var exercises: [LocalizedExercise] {
        switch self {
        case .abs:
            return [
                .init(nameKey: "exercise.name.basic_crunch", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.crunch_hands_to_knees", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.elevated_heel_touch", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.flutter_kick", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.front_scissors", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.knee_to_elbow_sit_up", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.leg_lowers", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_crunch", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.plank", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.reverse_crunch", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.russian_twist", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.side_plank", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.v_sit", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.windshield_wiper", categoryKey: categoryKey)
            ]

        case .arms:
            return [
                .init(nameKey: "exercise.name.barbell_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.barbell_skull_crusher", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_overhead_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_rope_pushdown", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.concentration_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.decline_tricep_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dip", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_decline_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_hammer_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_incline_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_kickback", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_overhead_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_skull_crusher", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.incline_triceps_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.lying_tricep_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_bicep_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_seated_dip", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.overhead_cable_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.preacher_curl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.spider_curl", categoryKey: categoryKey)
            ]

        case .back:
            return [
                .init(nameKey: "exercise.name.back_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.barbell_good_morning", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.barbell_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_one_arm_lat_pull", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_one_arm_pulldown", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_rope_pullover", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.chin_up", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.close_grip_pull", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_good_morning", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.lat_pulldown", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_lat_pulldown", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.pull_up", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.reverse_grip_pull", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.seated_cable_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.t_bar_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.wide_grip_pull", categoryKey: categoryKey)
            ]

        case .chest:
            return [
                .init(nameKey: "exercise.name.barbell_bench_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.barbell_decline_bench_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.barbell_incline_bench_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_chest_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_crossover", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_bench_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_decline_bench_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_decline_fly", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_incline_bench_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_incline_fly", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_pullover", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.low_cable_crossover", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_chest_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.pec_deck", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.push_up", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.single_arm_dumbbell_press", categoryKey: categoryKey)
            ]

        case .glutes:
            return [
                .init(nameKey: "exercise.name.cable_donkey_kick", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.glute_bridge", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.hip_thrust", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.kettlebell_swing", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_donkey_kick", categoryKey: categoryKey)
            ]

        case .legs:
            return [
                .init(nameKey: "exercise.name.back_squat", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.calf_raise", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_lateral_leg_raise", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_step_up", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.front_squat", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.lateral_lunge", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.leg_extension", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.leg_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.pistol_squat", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.reverse_lunge", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.romanian_deadlift", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.single_leg_rdl", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.sumo_deadlift", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.sumo_squat", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.traditional_deadlift", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.walking_lunge", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.side_leg_raise", categoryKey: categoryKey)
            ]

        case .shoulder:
            return [
                .init(nameKey: "exercise.name.barbell_shrug", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.barbell_upright_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_face_pull", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_one_arm_lateral_raise", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_rear_delt_fly", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_shrug", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.cable_upright_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_front_raise", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_lateral_raise", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_reverse_fly", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_shoulder_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_shrug", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.dumbbell_upright_row", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.landmine_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_lateral_raise", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_reverse_fly", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.machine_shoulder_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.military_press", categoryKey: categoryKey),
                .init(nameKey: "exercise.name.plate_front_raise", categoryKey: categoryKey)
            ]
        }
    }
}
