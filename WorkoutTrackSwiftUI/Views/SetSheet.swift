//
//  SetSheet.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/2/18.
//

import SwiftUI

struct SetSheet: View {
    @State private var reps: Int
    @State private var weight: Double
    
    let onSave: (Int, Double) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(initialReps: Int,
         initialWeight: Double,
         onSave: @escaping (Int, Double) -> Void) {
        _reps = State(initialValue: initialReps)
        _weight = State(initialValue: initialWeight)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Stepper("Reps: \(reps)", value: $reps, in: 0...100)
                    .monospaced()
                Stepper("Weight: \(weight, specifier: "%.1f") kg", value: $weight, in: 0...500, step: 0.5)
                    .monospaced()
            }
            .navigationTitle("Set")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(reps, weight)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SetSheet(initialReps: 10, initialWeight: 20.0, onSave: { _, _ in })
}
