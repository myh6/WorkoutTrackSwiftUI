//
//  DayCell.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/11/30.
//

import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasData: Bool
    let accentColor: Color
    let onTap: (Date) -> Void
    
    let selectionNamespace: Namespace.ID
    
    private var weekdayText: String {
        date.formatted(.dateTime.weekday(.narrow)).uppercased()
    }
    
    private var dayText: String {
        date.formatted(.dateTime.day())
    }
    
    private var primaryTextColor: Color {
        isSelected ? .white : .primary
    }
    
    private var weekdayTextColor: Color {
        isSelected ? .white.opacity(0.9) : .secondary
    }
    
    var body: some View {
        Button(action: select) {
            VStack(spacing: 2) {
                Text(weekdayText)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(weekdayTextColor)
                    .padding(.top, 2)
                Text(dayText)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(primaryTextColor)
                indicatorBar
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(selectionBackground)
        }
        .buttonStyle(.plain)
    }
    
    private func select() {
        onTap(date)
    }
    
    @ViewBuilder
    private var indicatorBar: some View {
        if hasData {
            RoundedRectangle(cornerRadius: 2)
                .fill(hasData ? isSelected ? .white : accentColor : .clear)
                .frame(width: 8, height: 3)
                .padding(.top, 2)
        } else {
            Spacer()
                .frame(height: 3)
                .padding(.top, 3)
        }
    }
    
    @ViewBuilder
    private var selectionBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(accentColor)
                .matchedGeometryEffect(id: "selection", in: selectionNamespace)
        } else { Color.clear }
    }
}


#Preview("With data") {
    DayCellPreviewWrapper(hasData: true)
        .preferredColorScheme(.light)
}

#Preview("With no data") {
    DayCellPreviewWrapper(hasData: false)
        .preferredColorScheme(.light)
}

private struct DayCellPreviewWrapper: View {
    @Namespace private var selectionNamespace
    
    private var hasData: Bool
    init(hasData: Bool) {
        self.hasData = hasData
    }
    
    var body: some View {
        HStack(spacing: 8) {
            DayCell(date: Date(), isSelected: false, hasData: hasData, accentColor: .accentColor, onTap: { _ in }, selectionNamespace: selectionNamespace)
            
            DayCell(date: Date(), isSelected: true, hasData: hasData, accentColor: .accentColor, onTap: { _ in }, selectionNamespace: selectionNamespace)
            
            DayCell(date: Date(), isSelected: false, hasData: hasData, accentColor: .accentColor, onTap: { _ in }, selectionNamespace: selectionNamespace)
        }
        .padding()
    }
}
