//
//  ContrastBrightnessSaturationFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 04/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

#if os(iOS)
import CoreImage
#elseif os(OSX)
import QuartzCore
#endif

/**
 *  The `ContrastBrightnessSaturationFilter` can be used to change the brightness, contrast or saturation of an image.
 */
@objc(IMGLYContrastBrightnessSaturationFilter) public class ContrastBrightnessSaturationFilter: CIFilter, Filter {
    /// A `CIImage` object that serves as input for the filter.
    public var inputImage: CIImage?

    /// The contrast value of the resulting image.
    /// 1.0 means no change.
    public var contrast: Float = 1.0

    /// The brightness value of the resulting image.
    /// 0.0 means no change.
    public var brightness: Float = 0.0

    /// The contrast value of the resulting image.
    /// 1.0 means no change, 0.0 will result in a grayscale image.
    public var saturation: Float = 1.0

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            return inputImage
        }

        contrastFilter.setValue(contrast, forKey: "inputContrast")
        contrastFilter.setValue(brightness, forKey: "inputBrightness")
        contrastFilter.setValue(saturation, forKey: "inputSaturation")
        contrastFilter.setValue(inputImage, forKey: kCIInputImageKey)
        return contrastFilter.outputImage
    }
}

extension ContrastBrightnessSaturationFilter {
    /**
     :nodoc:
     */
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! ContrastBrightnessSaturationFilter
        // swiftlint:enable force_cast
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.contrast = contrast
        copy.brightness = brightness
        copy.saturation = saturation
        return copy
    }
}
