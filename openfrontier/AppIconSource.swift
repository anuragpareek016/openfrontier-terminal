import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Generates the canonical OpenFrontier macOS app icon. The transparent canvas
// and inset squircle keep its optical size consistent with Apple's Dock icons.

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
    fputs("usage: swift AppIconSource.swift OUTPUT.png [SIZE]\n", stderr)
    exit(64)
}

let outputURL = URL(fileURLWithPath: arguments[1])
let pixelSize = arguments.count >= 3 ? (Int(arguments[2]) ?? 1024) : 1024
let scale = CGFloat(pixelSize) / 1024

guard
    let context = CGContext(
        data: nil,
        width: pixelSize,
        height: pixelSize,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
else {
    fatalError("Unable to create drawing context")
}

context.scaleBy(x: scale, y: scale)
context.clear(CGRect(x: 0, y: 0, width: 1024, height: 1024))

let tileRect = CGRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = CGPath(
    roundedRect: tileRect,
    cornerWidth: 190,
    cornerHeight: 190,
    transform: nil
)

context.saveGState()
context.addPath(tilePath)
context.clip()
let backgroundGradient = CGGradient(
    colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
    colors: [
        CGColor(red: 0.105, green: 0.115, blue: 0.135, alpha: 1),
        CGColor(red: 0.012, green: 0.014, blue: 0.020, alpha: 1),
    ] as CFArray,
    locations: [0, 1]
)!
context.drawLinearGradient(
    backgroundGradient,
    start: CGPoint(x: 512, y: 924),
    end: CGPoint(x: 512, y: 100),
    options: []
)

// A restrained highlight gives the tile depth without changing the mark.
context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.13))
context.setLineWidth(6)
context.addPath(
    CGPath(
        roundedRect: tileRect.insetBy(dx: 3, dy: 3),
        cornerWidth: 187,
        cornerHeight: 187,
        transform: nil
    )
)
context.strokePath()
context.restoreGState()

// OpenFrontier mark: an open orbit and forward point.
context.saveGState()
context.setStrokeColor(CGColor(gray: 1, alpha: 1))
context.setLineWidth(58)
context.setLineCap(.round)
context.addArc(
    center: CGPoint(x: 548, y: 512),
    radius: 268,
    startAngle: .pi * 0.82,
    endAngle: .pi * 1.18,
    clockwise: true
)
context.strokePath()

context.setFillColor(CGColor(gray: 1, alpha: 1))
context.fillEllipse(in: CGRect(x: 207, y: 441, width: 142, height: 142))
context.restoreGState()

guard let image = context.makeImage() else {
    fatalError("Unable to create icon image")
}

try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
) else {
    fatalError("Unable to create PNG destination")
}

CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("Unable to write icon PNG")
}
