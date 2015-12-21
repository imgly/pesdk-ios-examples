//
//  IMGLYStickerFilter.swift
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

public class IMGLYStickerFilter: CIFilter {
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

        if imageSize.width > imageSize.height {
            return CGSize(width: self.scale * imageSize.height, height: self.scale * stickerRatio * imageSize.height)
        }

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

extension IMGLYStickerFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYStickerFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.sticker = sticker
        copy.center = center
        copy.scale = scale
        copy.transform = transform
        copy.cropRect = cropRect
        return copy
    }
}
