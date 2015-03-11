//
//  IMGLYEnhancementFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 09/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
  This class uses apples auto-enhancement filters to improve the overall
  quality of an image. Due the way this filter is used within this SDK,
  there is a mechanism that retains the enhanced image until its resetted
  and a recalculation is foced. This behaviour is inactive by default, and
  can be activated by setting 'storeEnhancedImage' to true.
*/
public class IMGLYEnhancementFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    
    /// If this is set to false, the original image is returned.
    public var enabled = true
    
    /// If this is set to true, the enhanced image is kept until reset is called.
    public var storeEnhancedImage = false
    
    private var enhancedImage:CIImage? = nil
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    override public var outputImage: CIImage! {
        get {
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
    }
    
    public func reset() {
        enhancedImage = nil
    }
}