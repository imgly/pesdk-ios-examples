//
//  EnhancementFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 09/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import CoreImage

/**
  This class uses apples auto-enhancement filters to improve the overall
  quality of an image. Due the way this filter is used within this SDK,
  there is a mechanism that retains the enhanced image until its resetted
  and a recalculation is foced. This behaviour is inactive by default, and
  can be activated by setting 'storeEnhancedImage' to true.
*/
@objc(IMGLYEnhancementFilter) public class EnhancementFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    
    /// If this is set to false, the original image is returned.
    public var enabled = true
    
    /// If this is set to true, the enhanced image is kept until reset is called.
    public var storeEnhancedImage = false
    
    private var enhancedImage:CIImage? = nil
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
        if inputImage == nil {
            return CIImage.emptyImage()
        }
        
        if !enabled {
            return inputImage
        }
        
        if storeEnhancedImage {
            if enhancedImage != nil {
                return enhancedImage!
            }
        }
        
        var intermediateImage = inputImage
        var filters = intermediateImage!.autoAdjustmentFiltersWithOptions([kCIImageAutoAdjustRedEye:NSNumber(bool: false)])
        for filter in filters {
            filter.setValue(intermediateImage, forKey: kCIInputImageKey)
            intermediateImage = filter.outputImage
        }
        if storeEnhancedImage {
            enhancedImage = intermediateImage
        }
        return intermediateImage
    }
    
    public func reset() {
        enhancedImage = nil
    }
}

extension EnhancementFilter: NSCopying {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! EnhancementFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.enabled = enabled
        copy.storeEnhancedImage = storeEnhancedImage
        copy.enhancedImage = enhancedImage?.copyWithZone(zone) as? CIImage
        return copy
    }
}