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
@objc(IMGLYFixedFilterStack) public class FixedFilterStack: NSObject {
    
    // MARK: - Properties
    
    public var enhancementFilter: EnhancementFilter = {
        let filter = InstanceFactory.sharedInstance.enhancementFilter()
        filter.enabled = false
        filter.storeEnhancedImage = true
        return filter
        }()
    
    public var orientationCropFilter = InstanceFactory.sharedInstance.orientationCropFilter()
    public var effectFilter = InstanceFactory.sharedInstance.effectFilterWithType(FilterType.None)
    public var brightnessFilter = InstanceFactory.sharedInstance.colorAdjustmentFilter()
    public var tiltShiftFilter = InstanceFactory.sharedInstance.tiltShiftFilter()
    public var textFilter = InstanceFactory.sharedInstance.textFilter()
    public var stickerFilters = [CIFilter]()
    
    public var activeFilters: [CIFilter] {
        var activeFilters: [CIFilter] = [enhancementFilter, tiltShiftFilter, effectFilter, brightnessFilter, textFilter]
        activeFilters += stickerFilters
        activeFilters.append(orientationCropFilter)
        
        return activeFilters
    }
    
    // MARK: - Initializers
    
    required override public init () {
        super.init()
    }
}

extension FixedFilterStack: NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType()
        copy.enhancementFilter = enhancementFilter.copyWithZone(zone) as! EnhancementFilter
        copy.effectFilter = effectFilter.copyWithZone(zone) as! ResponseFilter
        copy.brightnessFilter = brightnessFilter.copyWithZone(zone) as! ContrastBrightnessSaturationFilter
        copy.tiltShiftFilter = tiltShiftFilter.copyWithZone(zone) as! TiltshiftFilter
        copy.textFilter = textFilter.copyWithZone(zone) as! TextFilter
        copy.stickerFilters = NSArray(array: stickerFilters, copyItems: true) as! [CIFilter]
        copy.orientationCropFilter = orientationCropFilter.copyWithZone(zone) as! OrientationCropFilter
        return copy
    }
}
