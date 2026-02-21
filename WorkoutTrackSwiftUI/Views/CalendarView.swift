//
//  CalendarView.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/12.
//

import SwiftUI

struct CalendarView: View {
    let accentColor: Color
    let hasDataForDate: (Date) -> Bool
    
    @StateObject private var viewModel: CalendarViewModel
    @Namespace private var selectionNamespace
    
    init(accentColor: Color, hasDataForDate: @escaping (Date) -> Bool, viewModel: CalendarViewModel) {
        self.accentColor = accentColor
        self.hasDataForDate = hasDataForDate
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 5) {

            header

            ZStack(alignment: .top) {
                if viewModel.mode == .weekly { weeklyStrip }
                if viewModel.mode == .monthly { monthGrid }
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: viewModel.mode)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 5) {
            Text(viewModel.titleText)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(accentColor)
            
            HStack(alignment: .center) {
                Button("Prev") { viewModel.movePrevious() }
                    .font(.footnote)
                    .foregroundStyle(accentColor)
                    .buttonStyle(.borderless)
                Spacer()
                
                Picker("",
                       selection: Binding(
                        get: { viewModel.mode },
                        set: { viewModel.setMode($0) })) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                
                Spacer()
                Button("Next") { viewModel.moveNext() }
                    .font(.footnote)
                    .foregroundStyle(accentColor)
                    .buttonStyle(.borderless)
            }
        }
    }

    // MARK: - Weekly

    private var weeklyStrip: some View {
        let days = viewModel.weekDates

        return HStack(spacing: 0) {
            ForEach(days, id: \.self) { date in
                populateDayCell(with: date)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedDate)
    }
    
    private func populateDayCell(with date: Date) -> DayCell {
        DayCell(
            date: date,
            isSelected: viewModel.isSelected(date),
            hasData: hasDataForDate(date),
            accentColor: accentColor,
            onTap: { tapped in viewModel.selectDate(tapped) },
            selectionNamespace: selectionNamespace
        )
    }

    // MARK: - Monthly

    private var monthGrid: some View {
        let model = viewModel.monthModel
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return VStack(spacing: 8) {

            LazyVGrid(columns: columns, spacing: 8) {
                // leading blanks
                ForEach(0..<model.leadingEmptyCount, id: \.self) { _ in
                    Color.clear
                        .frame(height: 52)
                }

                // actual days
                ForEach(model.days, id: \.self) { date in
                    populateDayCell(with: date)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedDate)
        }
    }
}

#Preview {
    CalendarView(
        accentColor: .blue,
        hasDataForDate: { date in
            Calendar.current.component(.day, from: date) % 2 == 0
        },
        viewModel: CalendarViewModel(calendar: Calendar.current, mode: .weekly, anchorDate: Date(), selectedDate: Date())
    )
}

