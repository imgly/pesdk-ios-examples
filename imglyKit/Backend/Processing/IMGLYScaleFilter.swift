//
//  IMGLYScaleFilter.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 24/06/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
    import CoreImage
    #elseif os(OSX)
    import AppKit
    import QuartzCore
#endif

public class IMGLYScaleFilter: CIFilter, FilterType {
    public var inputImage: CIImage?
    public var scale = Float(1)

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            return inputImage
        }

        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)

        return filter.outputImage
    }
}

extension IMGLYScaleFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYScaleFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.scale = scale
        return copy
    }
}
