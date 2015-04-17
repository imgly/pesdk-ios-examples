//
//  ResponseFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

@objc public protocol FilterTypeProtocol {
    var filterType: FilterType { get }
}

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
@objc(ResponseFilter) public class ResponseFilter: CIFilter, FilterTypeProtocol {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?
    public let responseName: String

    /// Returns the according filter type of the response filter.
    public var filterType: FilterType {
        return .None
    }
    
    private lazy var colorCubeData: NSData? = {
        return LUTToNSDataConverter.colorCubeDataFromLUT(self.responseName)
    }()
    
    init(responseName: String) {
        self.responseName = responseName
        super.init()
    }
    
    required public init(coder aDecoder: NSCoder) {
        self.responseName = ""
        super.init(coder: aDecoder)
    }
    
    public override var outputImage: CIImage! {
        if inputImage == nil {
            return CIImage.emptyImage()
        }
        
        if colorCubeData == nil {
            return inputImage
        }
        
        var filter = CIFilter(name: "CIColorCube")
        filter.setValue(colorCubeData, forKey: "inputCubeData")
        filter.setValue(64, forKey: "inputCubeDimension")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
}

extension ResponseFilter: NSCopying {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! ResponseFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.colorCubeData = colorCubeData?.copyWithZone(zone) as? NSData
        return copy
    }
}
