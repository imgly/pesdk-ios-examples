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

        guard let filter = CIFilter(name: "CISourceOverCompositing"), sticker = createStickerImage() else {
            return inputImage
        }

        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(sticker, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    public func absolutStickerSizeForImageSize(imageSize: CGSize) -> CGSize {
        let stickerRatio = sticker!.size.height / sticker!.size.width
        return CGSize(width: self.scale * imageSize.width, height: self.scale * stickerRatio * imageSize.width)
    }

    private func createStickerImage() -> CIImage? {
        guard let cgImage = sticker?.CGImage else {
            return nil
        }

        var image = CIImage(CGImage: cgImage)

        let inputImageRect = inputImage!.extent
        let inputImageSize = inputImageRect.size

        let originalInputImageSize = CGSize(width: round(inputImageSize.width / cropRect.width), height: round(inputImageSize.height / cropRect.height))
        let absoluteStickerSize = absolutStickerSizeForImageSize(originalInputImageSize)

        let stickerImageSize = image.extent.size
        let stickerScale = absoluteStickerSize.width / stickerImageSize.width

        var stickerCenter = CGPoint(x: center.x * originalInputImageSize.width, y: center.y * originalInputImageSize.height)
        stickerCenter.x -= (cropRect.origin.x * originalInputImageSize.width)
        stickerCenter.y -= (cropRect.origin.y * originalInputImageSize.height)

        let xScale = self.transform.xScale
        let yScale = self.transform.yScale
        let rotation = self.transform.rotation

        var transform = CGAffineTransformIdentity

        // Scale to match size of preview
        transform = CGAffineTransformScale(transform, stickerScale, stickerScale)

        // Translate
        // Calculate the origin of the sticker. Note that in CoreImage (0,0) is at the bottom
        let stickerOrigin = CGPoint(x: stickerCenter.x - absoluteStickerSize.width * xScale / 2, y: stickerCenter.y + absoluteStickerSize.height * yScale / 2)
        transform = CGAffineTransformTranslate(transform, stickerOrigin.x / stickerScale, (originalInputImageSize.height - stickerOrigin.y) / stickerScale)

        // Scale
        transform = CGAffineTransformScale(transform, xScale, yScale)

        // Rotate
        transform = CGAffineTransformTranslate(transform, 0.5 * stickerImageSize.width, 0.5 * stickerImageSize.height)
        transform = CGAffineTransformRotate(transform, -1 * rotation)
        transform = CGAffineTransformTranslate(transform, -0.5 * stickerImageSize.width, -0.5 * stickerImageSize.height)

        image = image.imageByApplyingTransform(transform)
        image = image.imageByCroppingToRect(inputImageRect)

        return image
    }

    // MARK: - Rotation

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

    // MARK: - Flipping

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
