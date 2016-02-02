//
//  ResponseFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
#if os(iOS)
import CoreImage
#elseif os(OSX)
import QuartzCore
#endif

/**
  A base clase for all response filters. Response filters use a look-up-table to
  map colors around, and create cool effects. These tables are handed over as image
  that contains serveral combination of r, g, and b values. Tools like photoshop can be used
  to create filters, using the identity-image and apply the desired operations onto it.
  Afterwards the so filtered image may be used as response map, as it represents the response the
  filter should have.
  In order to use the filter, the response-image is tranfered into a color-cube-map, that then
  can be used as input for a 'CIColorCube' filter, provided by core-image.
*/
@objc(IMGLYResponseFilter) public class ResponseFilter: CIFilter, Filter {
    private static let lutConverter = LUTToNSDataConverter(identityName: "Identity")

    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?
    public var inputIntensity = NSNumber(float: 1) {
        didSet {
            if oldValue != inputIntensity {
                colorCubeData = nil
            }
        }
    }

    public let responseName: String

    private var _colorCubeData: NSData?
    private var colorCubeData: NSData? {
        get {
            if _colorCubeData == nil {
                ResponseFilter.lutConverter.lutName = self.responseName
                ResponseFilter.lutConverter.intensity = self.inputIntensity.floatValue
                _colorCubeData = ResponseFilter.lutConverter.colorCubeData
            }

            return _colorCubeData
        }

        set {
            _colorCubeData = newValue
        }
    }

    public required convenience override init() {
        self.init(responseName: "")
    }

    init(responseName: String) {
        self.responseName = responseName
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.responseName = ""
        super.init(coder: aDecoder)
    }

    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        var outputImage: CIImage?

        autoreleasepool {
            if let colorCubeData = colorCubeData, filter = CIFilter(name: "CIColorCube") {
                filter.setValue(colorCubeData, forKey: "inputCubeData")
                filter.setValue(64, forKey: "inputCubeDimension")
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            } else {
                outputImage = inputImage
            }
        }

        return outputImage
    }
}

extension ResponseFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! ResponseFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.inputIntensity = inputIntensity.copyWithZone(zone) as! NSNumber
        copy._colorCubeData = _colorCubeData?.copyWithZone(zone) as? NSData
        // swiftlint:enable force_cast
        return copy
    }
}
