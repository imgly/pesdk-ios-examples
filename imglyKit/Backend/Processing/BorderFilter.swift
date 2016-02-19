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

    /// The transform to apply to the border.
    private var transform = CGAffineTransformIdentity

    /// The relative center of the border within the image.
    private var center = CGPoint()

    /// The crop-create applied to the input image, so we can adjust the border position
    public var cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

    /// The tolerance that is used to pick the correct border image based on the aspect ratio.
    public var tolerance = CGFloat(0.0)

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

        guard let filter = CIFilter(name: "CISourceOverCompositing"), border = createBorderImage() else {
            return inputImage
        }

        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(border, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    private func createBorderImage() -> CIImage? {
        let inputImageRect = inputImage!.extent
        let inputImageSize = inputImageRect.size
        let ratio = inputImageSize.width / inputImageSize.height
        guard let cgImage = border?.imageForRatio(Float(ratio), tolerance: Float(tolerance))?.CGImage else {
            return nil
        }

        var image = CIImage(CGImage: cgImage)
        let originalInputImageSize = CGSize(width: round(inputImageSize.width / cropRect.width), height: round(inputImageSize.height / cropRect.height))
        let absoluteBorderSize = originalInputImageSize

        let borderImageSize = image.extent.size
        let scaleX = absoluteBorderSize.width / borderImageSize.width
        let scaleY = absoluteBorderSize.height / borderImageSize.height

        var borderCenter = CGPoint(x: center.x * originalInputImageSize.width, y: center.y * originalInputImageSize.height)
        borderCenter.x -= (cropRect.origin.x * originalInputImageSize.width)
        borderCenter.y -= (cropRect.origin.y * originalInputImageSize.height)

        var transform = CGAffineTransformIdentity

        // Scale to match size of preview
        transform = CGAffineTransformScale(transform, scaleX, scaleY)
        image = image.imageByApplyingTransform(transform)
        image = image.imageByCroppingToRect(inputImageRect)

        return image
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
        copy.tolerance = tolerance
        copy.transform = transform
        copy.cropRect = cropRect
        return copy
    }
}
