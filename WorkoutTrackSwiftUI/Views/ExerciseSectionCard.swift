//
//  ExerciseSectionCard.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/26.
//

import SwiftUI

struct ExerciseSectionCard: View {
    let section: ExerciseSection
    
    let onToggleExpand: () -> Void
    let onToggleFinished: (UUID) -> Void // setID
    let onDeleteSet: (UUID) -> Void // setID
    let onAddSet: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            header
            
            if section.isExpanded {
                Divider()
                VStack(spacing: 10) {
                    ForEach(section.sets) { row in
                        SetRowView(
                            row: row,
                            onToggleFinished: { onToggleFinished(row.id) },
                            onDelete: { onDeleteSet(row.id) }
                            )
                    }
                    
                    Button(" + Add Set", action: onAddSet)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text(section.title)
            
            Spacer()
            
            Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggleExpand)
//        .previewOutline()
    }
}

#Preview {
    ExerciseSectionCard(
        section: ExerciseSection(
            id: UUID(),
            title: "Random exercise",
            sets: [
                SetRow(id: UUID(), reps: 10, weight: 20, isFinished: true, order: 0),
                SetRow(id: UUID(), reps: 1, weight: 30, isFinished: false, order: 1),
                SetRow(id: UUID(), reps: 100, weight: 0.5, isFinished: false, order: 2)],
            isExpanded: true),
        onToggleExpand: { },
        onToggleFinished: { _ in },
        onDeleteSet: { _ in },
        onAddSet: {  }
    )
}
