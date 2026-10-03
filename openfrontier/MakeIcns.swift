import Foundation

// Minimal ICNS packer for modern PNG-backed icon chunks. This avoids relying
// on iconutil, which is unavailable or broken on some beta macOS SDK hosts.

guard CommandLine.arguments.count == 3 else {
    fputs("usage: swift MakeIcns.swift ICONSET_DIRECTORY OUTPUT.icns\n", stderr)
    exit(64)
}

let iconsetURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

let chunks: [(type: String, filename: String)] = [
    ("icp4", "icon_16x16.png"),
    ("icp5", "icon_32x32.png"),
    ("icp6", "icon_32x32@2x.png"),
    ("ic07", "icon_128x128.png"),
    ("ic08", "icon_256x256.png"),
    ("ic09", "icon_512x512.png"),
    ("ic10", "icon_512x512@2x.png"),
    ("ic11", "icon_16x16@2x.png"),
    ("ic12", "icon_32x32@2x.png"),
    ("ic13", "icon_128x128@2x.png"),
    ("ic14", "icon_256x256@2x.png"),
]

func fourByteTag(_ value: String) -> Data {
    let bytes = Array(value.utf8)
    precondition(bytes.count == 4)
    return Data(bytes)
}

func bigEndianData(_ value: UInt32) -> Data {
    var encoded = value.bigEndian
    return Data(bytes: &encoded, count: MemoryLayout<UInt32>.size)
}

var body = Data()
for chunk in chunks {
    let pngURL = iconsetURL.appendingPathComponent(chunk.filename)
    let png = try Data(contentsOf: pngURL)
    body.append(fourByteTag(chunk.type))
    body.append(bigEndianData(UInt32(png.count + 8)))
    body.append(png)
}

var output = Data("icns".utf8)
output.append(bigEndianData(UInt32(body.count + 8)))
output.append(body)
try output.write(to: outputURL, options: .atomic)
