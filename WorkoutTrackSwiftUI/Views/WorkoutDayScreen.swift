//
//  WorkoutDayScreen.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/27.
//

import SwiftUI

struct WorkoutDayScreen: View {
    @StateObject var vm: WorkoutDayViewModel
    @State private var editingSet: SetSheetRoute?
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
            
            content
        }
        .task {
            if case .idle = vm.state {
                await vm.load()
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text(vm.selectedDate.formatted(date: .abbreviated, time: .omitted))
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().padding()
            
        case .empty:
            Text("No workout yet")
                .padding()
            
        case .failed(let message):
            VStack(spacing: 12) {
                Text(message)
                Button("Retry") { Task { await vm.load() } }
            }
        
        case .loaded(let sections):
            List {
                ForEach(sections) { section in
                    sectionHeader(section)
                    if section.isExpanded {
                        ForEach(section.sets) { row in
                            SetRowView(
                                row: row,
                                onToggleFinished: {
                                    Task {
                                        await vm.toggleSetFinished(entryID: section.id, setID: row.id)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await vm.deleteSet(entryID: section.id, setID: row.id)
                                    }
                                },
                                onEdit: {
                                    editingSet = .update(entryID: section.id, set: row)
                                }
                            )
                        }
                        
                        Button(" + Add Set") {
                            editingSet = .add(entryID: section.id)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .sheet(item: $editingSet) { route in
                setSheet(route)
                    .presentationDetents([.height(250)])
            }
        }
    }
}

extension WorkoutDayScreen {
    private func sectionHeader(_ section: ExerciseSection) -> some View {
        HStack {
            Text(section.title)
            
            Spacer()
            
            Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
        }
        .contentShape(Rectangle())
        .onTapGesture { vm.toggleExpanded(entryID: section.id) }
    }
    
    private func setSheet(_ route: SetSheetRoute) -> some View {
        switch route {
        case .add(let entryID):
            SetSheet(initialReps: 0, initialWeight: 0) { newReps, newWeight in
                Task {
                    await vm.addSet(weight: newWeight, reps: newReps, to: entryID)
                }
            }
        case .update(let entryID, let set):
            SetSheet(initialReps: set.reps, initialWeight: set.weight) { newReps, newWeight in
                Task {
                    await vm.updateSetReps(entryID: entryID, setID: set.id, reps: newReps)
                    await vm.updateSetWeight(entryID: entryID, setID: set.id, weight: newWeight)
                }
            }
        }
    }
}

#Preview {
    WorkoutDayScreen(
        vm: WorkoutDayViewModel(
            selectedDate: Date(),
            service: PreviewService.makeSample(selectedDate: Date()),
            calendar: Calendar.current)
    )
}
