//
//  StickerFilter.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 24/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
import UIKit
import CoreImage
#elseif os(OSX)
import AppKit
import QuartzCore
#endif

import CoreGraphics

@objc(IMGLYStickerFilter) public class StickerFilter: CIFilter, Filter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?

    /// The sticker that should be rendered.
    #if os(iOS)
    public var sticker: UIImage?
    #elseif os(OSX)
    public var sticker: NSImage?
    #endif

    /// The transform to apply to the sticker
    public var transform = CGAffineTransformIdentity

    /// The relative center of the sticker within the image.
    public var center = CGPoint()

    /// The relative scale of the sticker within the image.
    public var scale = CGFloat(1.0)

    /// The crop-create applied to the input image, so we can adjust the sticker position
    public var cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

    override init() {
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        if sticker == nil {
            return inputImage
        }

        let stickerImage = createStickerImage()

        guard let cgImage = stickerImage.CGImage, filter = CIFilter(name: "CISourceOverCompositing") else {
            return inputImage
        }

        let stickerCIImage = CIImage(CGImage: cgImage)
        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(stickerCIImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    public func absolutStickerSizeForImageSize(imageSize: CGSize) -> CGSize {
        let stickerRatio = sticker!.size.height / sticker!.size.width
        return CGSize(width: self.scale * imageSize.width, height: self.scale * stickerRatio * imageSize.width)
    }

    #if os(iOS)

    private func createStickerImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))

        if let context = UIGraphicsGetCurrentContext() {
            drawStickerInContext(context, withImageOfSize: imageSize)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    #elseif os(OSX)

    private func createStickerImage() -> NSImage {
        let rect = inputImage!.extent
        let imageSize = rect.size

        let image = NSImage(size: imageSize)
        image.lockFocus()
        NSColor(white: 1, alpha: 0).setFill()
        NSRectFill(CGRect(origin: CGPoint(), size: imageSize))

        let context = NSGraphicsContext.currentContext()!.CGContext
        drawStickerInContext(context, withImageOfSize: imageSize)

        image.unlockFocus()

        return image
    }

    #endif

    // MARK:- rotation

    public func rotateRight () {
        rotate(CGFloat(M_PI_2), negateX: true, negateY: false)
    }

    public func rotateLeft () {
        rotate(CGFloat(-M_PI_2), negateX: false, negateY: true)
    }

    private func rotate(angle: CGFloat, negateX: Bool, negateY: Bool) {
        let xFactor: CGFloat = negateX ? -1.0 : 1.0
        let yFactor: CGFloat = negateY ? -1.0 : 1.0

        self.transform = CGAffineTransformRotate(self.transform, angle)
        self.center.x -= 0.5
        self.center.y -= 0.5
        let center = self.center
        self.center.x = xFactor * center.y
        self.center.y = yFactor * center.x
        self.center.x += 0.5
        self.center.y += 0.5
    }

    // MARK:- flipping

    public func flipStickersHorizontal () {
        flipSticker(true)
    }

    public func flipStickersVertical () {
        flipSticker(false)
    }

    private func flipSticker(horizontal: Bool) {
        #if os(iOS)
        if let sticker = self.sticker {
            let flippedOrientation = UIImageOrientation(rawValue:(sticker.imageOrientation.rawValue + 4) % 8)
            self.sticker = UIImage(CGImage: sticker.CGImage!, scale: sticker.scale, orientation: flippedOrientation!)
        }
        self.center.x -= 0.5
        self.center.y -= 0.5
        let center = self.center
        if horizontal {
            flipRotationHorizontal(self)
            self.center.x = -center.x
        } else {
            flipRotationVertical(self)
            self.center.y = -center.y
        }
        self.center.x += 0.5
        self.center.y += 0.5
        #endif
    }

    private func flipRotationHorizontal(stickerFilter: StickerFilter) {
        flipRotation(CGFloat(M_PI))
    }

    private func flipRotationVertical(stickerFilter: StickerFilter) {
        flipRotation(CGFloat(M_PI_2))
    }

    private func flipRotation(axisAngle: CGFloat) {
        var angle = atan2(self.transform.b, self.transform.a)
        let twoPI = CGFloat(M_PI * 2.0)
        // normalize angle
        while angle >= twoPI {
            angle -= twoPI
        }

        while angle < 0 {
            angle += twoPI
        }

        let delta = axisAngle - angle
        self.transform = CGAffineTransformRotate(self.transform, delta * 2.0)
    }

    // MARK:- drawing

    private func drawStickerInContext(context: CGContextRef, withImageOfSize imageSize: CGSize) {
        CGContextSaveGState(context)

        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        var center = CGPoint(x: self.center.x * originalSize.width, y: self.center.y * originalSize.height)
        center.x -= (cropRect.origin.x * originalSize.width)
        center.y -= (cropRect.origin.y * originalSize.height)

        let size = self.absolutStickerSizeForImageSize(originalSize)
        let imageRect = CGRect(origin: center, size: size)

        // Move center to origin
        CGContextTranslateCTM(context, imageRect.origin.x, imageRect.origin.y)
        // Apply the transform
        CGContextConcatCTM(context, self.transform)
        // Move the origin back by half
        CGContextTranslateCTM(context, imageRect.size.width * -0.5, imageRect.size.height * -0.5)

        sticker?.drawInRect(CGRect(origin: CGPoint(), size: size))
        CGContextRestoreGState(context)
    }
}

extension StickerFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! StickerFilter
        // swiftlint:enable force_cast
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.sticker = sticker
        copy.center = center
        copy.scale = scale
        copy.transform = transform
        copy.cropRect = cropRect
        return copy
    }
}
