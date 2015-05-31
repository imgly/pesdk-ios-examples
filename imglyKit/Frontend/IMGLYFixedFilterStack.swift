//
//  FixedFilterStack.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import CoreImage

/**
*   This class represents the filterstack that is used when using the UI.
*   It represents a chain of filters that will be applied to the taken image.
*   That way we make sure the order of filters stays the same, and we don't need to take
*   care about creating the single filters.
*/
public class IMGLYFixedFilterStack: NSObject {
    
    // MARK: - Properties
    
    public var enhancementFilter: IMGLYEnhancementFilter = {
        let filter = IMGLYInstanceFactory.enhancementFilter()
        filter.enabled = false
        filter.storeEnhancedImage = true
        return filter
        }()
    
    public var orientationCropFilter = IMGLYInstanceFactory.orientationCropFilter()
    public var effectFilter = IMGLYInstanceFactory.effectFilterWithType(IMGLYFilterType.None)
    public var brightnessFilter = IMGLYInstanceFactory.colorAdjustmentFilter()
    public var tiltShiftFilter = IMGLYInstanceFactory.tiltShiftFilter()
    public var textFilter = IMGLYInstanceFactory.textFilter()
    public var stickerFilters = [CIFilter]()
    
    public var activeFilters: [CIFilter] {
        var activeFilters: [CIFilter] = [enhancementFilter, orientationCropFilter, tiltShiftFilter, effectFilter, brightnessFilter, textFilter]
        activeFilters += stickerFilters
        
        return activeFilters
    }
    
    // MARK: - Initializers
    
    required override public init () {
        super.init()
    }
}

extension IMGLYFixedFilterStack: NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType()
        copy.enhancementFilter = enhancementFilter.copyWithZone(zone) as! IMGLYEnhancementFilter
        copy.orientationCropFilter = orientationCropFilter.copyWithZone(zone) as! IMGLYOrientationCropFilter
        copy.effectFilter = effectFilter.copyWithZone(zone) as! IMGLYResponseFilter
        copy.brightnessFilter = brightnessFilter.copyWithZone(zone) as! IMGLYContrastBrightnessSaturationFilter
        copy.tiltShiftFilter = tiltShiftFilter.copyWithZone(zone) as! IMGLYTiltshiftFilter
        copy.textFilter = textFilter.copyWithZone(zone) as! IMGLYTextFilter
        copy.stickerFilters = NSArray(array: stickerFilters, copyItems: true) as! [CIFilter]
        return copy
    }
}
