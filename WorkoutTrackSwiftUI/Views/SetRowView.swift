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
    
    var body: some View {
        HStack {
            Text("\(row.order + 1)")
            Spacer()
            Text(String(format: "%.1f kg", row.weight))
            Text("x \(row.reps) reps")
            
            Button(action: onToggleFinished) {
                Image(systemName: row.isFinished ? "checkmark.square" : "square")
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
    }
}

#Preview {
    VStack {
        SetRowView(row: SetRow(id: UUID(), reps: 10, weight: 20, isFinished: false, order: 0)) {
        } onDelete: {  }
        
        SetRowView(row: SetRow(id: UUID(), reps: 10, weight: 20, isFinished: true, order: 0)) {
        } onDelete: {  }
    }
}
