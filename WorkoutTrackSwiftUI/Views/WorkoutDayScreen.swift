//
//  WorkoutDayScreen.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2026/1/27.
//

import SwiftUI

struct WorkoutDayScreen: View {
    @StateObject var vm: WorkoutDayViewModel
    
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
            WorkoutDayListView(
                sections: sections) { entryID in
                    vm.toggleExpanded(entryID: entryID)
                } onToggleFinished: { entryID, setID in
                    Task { await vm.toggleSetFinished(entryID: entryID, setID: setID) }
                } onDeleteSet: { entryID, setID in
                    Task { await vm.deleteSet(entryID: entryID, setID: setID) }
                } onAddSet: { entryID in
                    Task { await vm.addSet(weight: 20, reps: 10, to: entryID) }
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
