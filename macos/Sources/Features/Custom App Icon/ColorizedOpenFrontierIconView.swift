import SwiftUI
import Cocoa

// For testing.
struct ColorizedOpenFrontierIconView: View {
    var body: some View {
        Image(nsImage: ColorizedOpenFrontierIcon(
            screenColors: [.purple, .blue],
            ghostColor: .yellow,
            frame: .aluminum
        ).makeImage(in: .main)!)
    }
}
