//
//  WorkoutDayListView.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/26.
//

import SwiftUI

struct WorkoutDayListView: View {
    let sections: [ExerciseSection]
    let onToggleExpanded: (UUID) -> Void        // entryID
    let onToggleFinished: (UUID, UUID) -> Void  // entryID, setID
    let onDeleteSet: (UUID, UUID) -> Void       // entryID, setID
    let onAddSet: (UUID) -> Void                // entryID
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sections, id: \.id) { section in
                    ExerciseSectionCard(
                        section: section,
                        onToggleExpand: { onToggleExpanded(section.id) },
                        onToggleFinished: { setID in onToggleFinished(section.id, setID) },
                        onDeleteSet: { setID in onDeleteSet(section.id, setID) },
                        onAddSet: { onAddSet(section.id) })
                }
            }
            .padding()
        }
    }
}

#Preview {
    WorkoutDayListView(
        sections: [
            ExerciseSection(
                id: UUID(),
                title: "Exercise A",
                sets: [
                    SetRow(id: UUID(), reps: 20, weight: 40, isFinished: true, order: 0),
                    SetRow(id: UUID(), reps: 10, weight: 80, isFinished: true, order: 1),
                    SetRow(id: UUID(), reps: 15, weight: 90, isFinished: false, order: 2),
                    SetRow(id: UUID(), reps: 15, weight: 90, isFinished: false, order: 3)
                ],
                isExpanded: true),
            ExerciseSection(
                id: UUID(),
                title: "Exercise B",
                sets: [
                    SetRow(id: UUID(), reps: 20, weight: 40, isFinished: false, order: 0)
                ],
                isExpanded: false),
            ExerciseSection(
                id: UUID(),
                title: "Exercise C",
                sets: [
                    SetRow(id: UUID(), reps: 20, weight: 40, isFinished: false, order: 0)
                ],
                isExpanded: true),
        ],
        onToggleExpanded: { _ in },
        onToggleFinished: { _, _ in },
        onDeleteSet: { _, _ in },
        onAddSet: { _ in })
}
