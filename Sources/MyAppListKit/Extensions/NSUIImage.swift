//
//  NSUIImage.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSImage {
    public func resized(to newSize: NSSize) -> NSImage {
        // 优先选择最佳的 NSImageRep（矢量图/位图时更清晰）
        if let rep = self.bestRepresentation(for: CGRect(origin: .zero, size: newSize),
                                             context: nil,
                                             hints: nil) {
            let image = NSImage(size: newSize)
            image.lockFocus()
            NSGraphicsContext.current?.imageInterpolation = .high
            defer { image.unlockFocus() }
            rep.draw(in: CGRect(origin: .zero, size: newSize))
            return image
        }
        // fallback: 常规缩放绘制
        let image = NSImage(size: newSize)
        image.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: CGRect(origin: .zero, size: newSize),
                  from: CGRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        image.unlockFocus()
        return image
    }
    public func toPNGData(scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 2.0) -> Data? {
        let size = self.size
        let pixelWidth = Int(size.width * scale)
        let pixelHeight = Int(size.height * scale)
        let rect = NSRect(origin: .zero, size: size)

        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelWidth,
            pixelsHigh: pixelHeight,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { return nil }

        NSGraphicsContext.saveGraphicsState()
        if let context = NSGraphicsContext(bitmapImageRep: rep) {
            context.cgContext.scaleBy(x: scale, y: scale) // 考虑 Retina 缩放
            NSGraphicsContext.current = context
            NSGraphicsContext.current?.imageInterpolation = .high // 提升插值质量
            self.draw(in: rect)
            context.flushGraphics()
        }
        NSGraphicsContext.restoreGraphicsState()

        return rep.representation(using: .png, properties: [:])
    }
}
#elseif canImport(UIKit)
import UIKit

extension UIImage {
    public func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    func toData() -> Data? {
        return self.pngData()
    }
}
#endif
