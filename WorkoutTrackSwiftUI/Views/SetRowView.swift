//
//  SetRowView.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/25.
//

import SwiftUI

struct SetRowView: View {
    let row: SetRow
    let onToggleFinished: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            Text("\(row.order + 1)")
            Spacer()
            Text(String(format: "%.1f kg", row.weight))
                .monospaced()
            Text("x \(row.reps) reps")
                .monospaced()
            
            Button(action: onToggleFinished) {
                Image(systemName: row.isFinished ? "checkmark.square" : "square")
            }
        }
        .padding(8)
        .swipeActions {
            Button(action: onDelete) { Image(systemName: "trash") }.tint(.red)
            Button(action: onEdit) { Image(systemName: "pencil") }
        }
    }
}

#Preview {
    VStack {
        SetRowView(row: SetRow(id: UUID(), reps: 10, weight: 20, isFinished: false, order: 0)) {
        } onDelete: {  } onEdit: {  }
        
        SetRowView(row: SetRow(id: UUID(), reps: 10, weight: 20, isFinished: true, order: 0)) {
        } onDelete: {  } onEdit: {}
    }
}
