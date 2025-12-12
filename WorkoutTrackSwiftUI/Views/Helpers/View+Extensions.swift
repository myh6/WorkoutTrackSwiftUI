//
//  View+Extensions.swift
//  WorkoutTrackSwiftUI
//
//  Created by Min-Yang Huang on 2025/12/11.
//

import SwiftUI

public extension View {
    /// Overlays a rounded rectangle outline only when running in Xcode Previews (Canvas).
    ///
    /// This helper is gated to appear only in preview environments, so it does not affect release builds.
    ///
    /// - Parameters:
    ///   - color: The color of the outline. Default is `.red`.
    ///   - lineWidth: The width of the outline line. Default is `1`.
    ///   - cornerRadius: The corner radius of the rounded rectangle. Default is `8`.
    ///
    /// - Returns: The view with an overlay outline only visible in previews.
    @ViewBuilder
    func previewOutline(_ color: Color = .red, lineWidth: CGFloat = 1, cornerRadius: CGFloat = 8) -> some View {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            self.overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(color, lineWidth: lineWidth)
            )
        } else {
            self
        }
#else
        self
#endif
    }
}
