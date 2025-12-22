//
//  NSUIImage.swift
//  MyAppListKit
//
//  Created by wong on 9/21/25.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSImage {
    /// 高性能图片缩放方法（支持 Retina 屏幕）
    public func resized(to newSize: NSSize) -> NSImage {
        // 1. 尺寸验证 - 无效尺寸返回原图
        guard newSize.width > 0 && newSize.height > 0 else { return self }
        
        // 2. 如果尺寸相同，直接返回副本
        if self.size == newSize {
            return (self.copy() as? NSImage) ?? self
        }
        // 3. 获取屏幕缩放因子（支持 Retina）
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        // 4. 使用 CGImage 进行高性能缩放
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return fallbackResize(to: newSize, scale: scale)
        }
        // 5. 计算实际像素尺寸（Retina 需要 2x 或 3x）
        let pixelWidth = Int(newSize.width * scale)
        let pixelHeight = Int(newSize.height * scale)
        let bitsPerComponent = 8
        let bytesPerRow = pixelWidth * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return fallbackResize(to: newSize, scale: scale)
        }
        
        // 设置高质量插值
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        
        guard let scaledCGImage = context.makeImage() else {
            return fallbackResize(to: newSize, scale: scale)
        }
        
        // 6. 创建 NSImage 并设置正确的表示
        let resultImage = NSImage(size: newSize)
        let rep = NSBitmapImageRep(cgImage: scaledCGImage)
        rep.size = newSize  // 设置逻辑尺寸，保持 scale factor
        resultImage.addRepresentation(rep)
        
        return resultImage
    }
    
    /// 备用缩放方法（当 CGImage 方法失败时使用）
    private func fallbackResize(to newSize: NSSize, scale: CGFloat) -> NSImage {
        let pixelSize = NSSize(width: newSize.width * scale, height: newSize.height * scale)
        
        let image = NSImage(size: newSize)
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(pixelSize.width),
            pixelsHigh: Int(pixelSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        
        guard let rep = rep else {
            // 最后的降级方案
            let fallbackImage = NSImage(size: newSize)
            fallbackImage.lockFocus()
            defer { fallbackImage.unlockFocus() }
            NSGraphicsContext.current?.imageInterpolation = .high
            self.draw(in: CGRect(origin: .zero, size: newSize),
                      from: CGRect(origin: .zero, size: self.size),
                      operation: .copy,
                      fraction: 1.0)
            return fallbackImage
        }
        
        rep.size = newSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        NSGraphicsContext.current?.imageInterpolation = .high
        
        self.draw(in: CGRect(origin: .zero, size: pixelSize),
                  from: CGRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        
        NSGraphicsContext.restoreGraphicsState()
        
        image.addRepresentation(rep)
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
