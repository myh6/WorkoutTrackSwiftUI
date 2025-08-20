//
//  File.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/20.
//

import SwiftUI

public struct CustomButton: View {
    var action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Text("Hello World")
        }
    }
}
