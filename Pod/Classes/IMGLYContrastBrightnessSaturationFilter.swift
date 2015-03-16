//
//  IMGLYContrastFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 04/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

public class IMGLYContrastBrightnessSaturationFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    
    public var contrast:Float = 1.0
    public var brightness:Float = 0.0
    public var saturation:Float = 1.0
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            var contrastFilter = CIFilter(name:"CIColorControls")
            contrastFilter.setValue(contrast, forKey: "inputContrast")
            contrastFilter.setValue(brightness, forKey: "inputBrightness")
            contrastFilter.setValue(saturation, forKey: "inputSaturation")
            contrastFilter.setValue(inputImage, forKey: kCIInputImageKey)
            return contrastFilter.outputImage
        }
    }
}