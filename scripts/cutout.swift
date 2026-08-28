import Foundation
import Vision
import CoreImage
import AppKit

let args = CommandLine.arguments
guard args.count == 3 else { print("usage: cutout <in> <out.png>"); exit(2) }
let inURL = URL(fileURLWithPath: args[1])
let outURL = URL(fileURLWithPath: args[2])

let request = VNGenerateForegroundInstanceMaskRequest()
let handler = VNImageRequestHandler(url: inURL, options: [:])
do {
    try handler.perform([request])
} catch {
    print("vision failed: \(error)"); exit(1)
}
guard let result = request.results?.first else {
    print("no foreground subject found"); exit(1)
}
print("instances found: \(result.allInstances.count)")
do {
    let buf = try result.generateMaskedImage(ofInstances: result.allInstances,
                                             from: handler,
                                             croppedToInstancesExtent: false)
    let ci = CIImage(cvPixelBuffer: buf)
    let ctx = CIContext()
    guard let cs = CGColorSpace(name: CGColorSpace.sRGB) else { exit(1) }
    try ctx.writePNGRepresentation(of: ci, to: outURL, format: .RGBA8, colorSpace: cs)
    print("wrote \(outURL.path)")
} catch {
    print("mask failed: \(error)"); exit(1)
}
