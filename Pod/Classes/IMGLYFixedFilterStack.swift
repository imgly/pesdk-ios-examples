
//
//  IMGLYFixedFilterStack.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

/**
    This class represents the filterstack that is used when using the UI.
    It represents a chain of filters that will be applied to the taken image.
    That way we make sure the order of filters stays the same, and we don't to take 
    care about creating the single filters.
*/
@objc public class IMGLYFixedFilterStack {
    public var sourceFilter:IMGLYSourcePhotoFilter?
    public var enhancementFilter:IMGLYEnhancementFilter?
    public var orientationCropFilter:IMGLYOrientationCropFilter?
    public var effectFilter:IMGLYResponseFilter?
    public var brightnessFitler:IMGLYContrastBrightnessSaturationFilter?
    public var tiltShiftFilter:IMGLYTiltshiftFilter?
    public var textFilter:IMGLYTextFilter?
    
    var activeFilters_:[CIFilter] = []
    public var activeFilters:[CIFilter] {
        get {
            rebuildFilterStack()
            return activeFilters_
        }
        set (filters) {
            activeFilters_ = filters
        }
    }
    
    public init() {
        setupDefaultFilterStack()
        rebuildFilterStack()
    }
    
    private func setupDefaultFilterStack() {
        sourceFilter = IMGLYSourcePhotoFilter()
        enhancementFilter = IMGLYInstanceFactory.sharedInstance.enhancementFilter()
        enhancementFilter!.enabled = false
        enhancementFilter!.storeEnhancedImage = true
        orientationCropFilter =  IMGLYInstanceFactory.sharedInstance.orientationCropFilter()
        tiltShiftFilter = IMGLYInstanceFactory.sharedInstance.tiltShiftFilter()
        effectFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(IMGLYFilterType.None) as? IMGLYResponseFilter
        brightnessFitler = IMGLYInstanceFactory.sharedInstance.colorAdjustmentFilter()
        textFilter = IMGLYInstanceFactory.sharedInstance.textFilter()
    }
    
    private func rebuildFilterStack() {
        self.activeFilters_  = []
        activeFilters_.append(sourceFilter!)
        activeFilters_.append(enhancementFilter!)
        activeFilters_.append(orientationCropFilter!)
        activeFilters_.append(tiltShiftFilter!)
        activeFilters_.append(effectFilter!)
        activeFilters_.append(brightnessFitler!)
        activeFilters_.append(textFilter!)
    }
    
    private func appendFilterIfValid(#filter:CIFilter?) {
        if filter != nil {
            activeFilters_.append(filter!)
        }
    }
}