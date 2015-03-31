//
//  MyCustomFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

@objc public protocol IMGLYFilterTypeProtocol {
    var filterType:IMGLYFilterType { get }
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
public class IMGLYResponseFilter: CIFilter, IMGLYFilterTypeProtocol {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    public var responseName: NSString {
        get {
            return responseName_
        }
        set(newName) {
            responseName_ = newName as! String
            var converter = LUTToNSDataConverter()
            colorCubeData_ = converter.colorCubeDataFromLUT(responseName_)
        }
    }
    
    /// Returns the acording filter type of the response filter.
    public var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.None
        }
    }
    
    private var colorCubeData_:AnyObject?
    private var responseName_: String = ""
    
    override init() {
        super.init()
        colorCubeData_ = nil
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            
            if colorCubeData_ == nil {
                return inputImage
            }
            
            var filter = CIFilter(name: "CIColorCube")
            filter.setValue(colorCubeData_, forKey: "inputCubeData")
            filter.setValue(64, forKey: "inputCubeDimension")
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            return filter.outputImage
        }
    }
    
    /**
        Forces ARC to release the color-cube-data.
    */
    deinit {
        colorCubeData_ = nil
    }
    
}
