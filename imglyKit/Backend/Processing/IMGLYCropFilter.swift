//
//  IMGLYCropFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 17/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
import CoreImage
#elseif os(OSX)
import QuartzCore
#endif

import CoreGraphics

/**
   Provides a filter to crop images.
*/
public class IMGLYCropFilter: CIFilter, FilterType {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?

    /// A rect that describes the area that should remain after cropping.
    /// The values are relative.
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

        let rect = inputImage.extent

        // important: CICrop has its coordinate system upside-down
        // so we need to reverse that
        let scaledRect = CGRect(x: rect.origin.x + cropRect.origin.x * rect.size.width,
            y: rect.origin.y + (rect.size.height - cropRect.origin.y * rect.size.height),
            width: cropRect.size.width * rect.size.width,
            height: -cropRect.size.height * rect.size.height)

        let croppedImage = inputImage.imageByCroppingToRect(scaledRect)

        // CICrop does not actually crop the image, but rather hides parts of the image
        // To actually get the cropped contents only, we have to apply a transform
        let croppedImageRect = croppedImage.extent
        let transformedImage = croppedImage.imageByApplyingTransform(CGAffineTransformMakeTranslation(-1 * croppedImageRect.origin.x, -1 * croppedImageRect.origin.y))

        return transformedImage
    }
}

extension IMGLYCropFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! IMGLYCropFilter
        // swiftlint:enable force_cast
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.cropRect = cropRect
        return copy
    }
}
