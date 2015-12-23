//
//  ScaleFilter.swift
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

@objc(IMGLYScaleFilter) public class ScaleFilter: CIFilter, Filter {
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

extension ScaleFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! ScaleFilter
        // swiftlint:enable force_cast
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.scale = scale
        return copy
    }
}
