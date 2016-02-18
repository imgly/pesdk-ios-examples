//
//  BorderFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 18/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//


#if os(iOS)
    import UIKit
    import CoreImage
#elseif os(OSX)
    import AppKit
    import QuartzCore
#endif

import CoreGraphics

@objc(IMGLYBorderFilter) public class BorderFilter: CIFilter, Filter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?

    /// The border that should be rendered.
    public var border: Border?

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

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        if border == nil {
            return inputImage
        }

        guard let filter = CIFilter(name: "CISourceOverCompositing"), sticker = createStickerImage() else {
            return inputImage
        }

        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(sticker, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    public func absoluteStickerSizeForImageSize(imageSize: CGSize) -> CGSize {
        let stickerRatio = CGFloat(1.0)

        if imageSize.width > imageSize.height {
            return CGSize(width: self.scale * imageSize.height, height: self.scale * stickerRatio * imageSize.height)
        }

        return CGSize(width: self.scale * imageSize.width, height: self.scale * stickerRatio * imageSize.width)
    }

    private func createStickerImage() -> CIImage? {
        guard let cgImage = border?.imageForRatio(1.0)?.CGImage else {
            return nil
        }

        var image = CIImage(CGImage: cgImage)

        let inputImageRect = inputImage!.extent
        let inputImageSize = inputImageRect.size

        let originalInputImageSize = CGSize(width: round(inputImageSize.width / cropRect.width), height: round(inputImageSize.height / cropRect.height))
        let absoluteStickerSize = absoluteStickerSizeForImageSize(originalInputImageSize)

        let stickerImageSize = image.extent.size
        let stickerScaleX = absoluteStickerSize.width / stickerImageSize.width
        let stickerScaleY = absoluteStickerSize.height / stickerImageSize.height

        var stickerCenter = CGPoint(x: center.x * originalInputImageSize.width, y: center.y * originalInputImageSize.height)
        stickerCenter.x -= (cropRect.origin.x * originalInputImageSize.width)
        stickerCenter.y -= (cropRect.origin.y * originalInputImageSize.height)

        let xScale = self.transform.xScale
        let yScale = self.transform.yScale
        let rotation = self.transform.rotation

        var transform = CGAffineTransformIdentity

        // Scale to match size of preview
        transform = CGAffineTransformScale(transform, stickerScaleX, stickerScaleY)

        // Translate
        // Calculate the origin of the sticker. Note that in CoreImage (0,0) is at the bottom
        let stickerOrigin = CGPoint(x: stickerCenter.x - absoluteStickerSize.width * xScale / 2, y: stickerCenter.y + absoluteStickerSize.height * yScale / 2)
        transform = CGAffineTransformTranslate(transform, stickerOrigin.x / stickerScaleX, (inputImageSize.height - stickerOrigin.y) / stickerScaleY)

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
}

extension BorderFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! BorderFilter
        // swiftlint:enable force_cast
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.border = border
        copy.center = center
        copy.scale = scale
        copy.transform = transform
        copy.cropRect = cropRect
        return copy
    }
}
