//
//  IMGLYCropFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 17/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
   Provides a filter to crop images.
*/
public class IMGLYCropFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    
    /// A rect that describes the area that should remain after cropping. 
    /// The values are relative.
    public var cropRect = CGRectMake(0, 0, 1, 1)
    
    override init() {
        super.init()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            var rect = inputImage!.extent()
            // important: CICrop has its coordinate system upside-down
            // so we need to reverse that 
            var scaledRect = CGRectMake(cropRect.origin.x * rect.width,
                rect.height - cropRect.origin.y * rect.height,
                cropRect.size.width * rect.width,
                -cropRect.size.height * rect.height)
            var rectAsVector = CIVector(CGRect: scaledRect)
            var cropFilter = CIFilter(name: "CICrop")
            cropFilter.setValue(inputImage!, forKey: kCIInputImageKey)
            cropFilter.setValue(rectAsVector, forKey: "inputRectangle")
            return cropFilter.outputImage
        }
    }
}
