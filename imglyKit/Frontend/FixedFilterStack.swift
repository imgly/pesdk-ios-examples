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
        let filter = InstanceFactory.enhancementFilter()
        filter.enabled = false
        filter.storeEnhancedImage = true
        return filter
        }()

    public var orientationCropFilter = InstanceFactory.orientationCropFilter()
    public var effectFilter = InstanceFactory.effectFilterWithType(FilterType.None)
    public var brightnessFilter = InstanceFactory.colorAdjustmentFilter()
    public var tiltShiftFilter = InstanceFactory.tiltShiftFilter()
    public var borderFilter = InstanceFactory.borderFilter()
    public var spriteFilters = [Filter]()

    public var activeFilters: [Filter] {
        setCropRectForStickerFilters()
        setCropRectForTextFilters()
        var activeFilters: [Filter] = [enhancementFilter, orientationCropFilter, tiltShiftFilter, effectFilter, brightnessFilter, borderFilter]
        activeFilters += spriteFilters
        return activeFilters
    }

    private func setCropRectForStickerFilters () {
        for stickerFilter in spriteFilters where stickerFilter is StickerFilter {
            // swiftlint:disable force_cast
            (stickerFilter as! StickerFilter).cropRect = orientationCropFilter.cropRect
            // swiftlint:enable force_fast
        }
    }

    private func setCropRectForTextFilters () {
        for textFilter in spriteFilters where textFilter is TextFilter {
            // swiftlint:disable force_cast
            (textFilter as! TextFilter).cropRect = orientationCropFilter.cropRect
            // swiftlint:enable force_fast
        }
    }

    public func rotateStickersRight () {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? StickerFilter {
                stickerFilter.rotateRight()
            }
        }
    }

    public func rotateStickersLeft () {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? StickerFilter {
                stickerFilter.rotateLeft()
            }
        }
    }

    public func rotateTextRight () {
        for filter in self.activeFilters {
            if let textFilter = filter as? TextFilter {
                textFilter.rotateTextRight()
            }
        }
    }

    public func rotateTextLeft () {
        for filter in self.activeFilters {
            if let textFilter = filter as? TextFilter {
                textFilter.rotateTextLeft()
            }
        }
    }

    public func flipStickersHorizontal () {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? StickerFilter {
                stickerFilter.flipStickersHorizontal()
            }
        }
    }

    public func flipStickersVertical () {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? StickerFilter {
                stickerFilter.flipStickersVertical()
            }
        }
    }

    public func flipTextHorizontal () {
        for filter in self.activeFilters {
            if let textFilter = filter as? TextFilter {
                textFilter.flipTextHorizontal()
            }
        }
    }

    public func flipTextVertical () {
        for filter in self.activeFilters {
            if let textFilter = filter as? TextFilter {
                textFilter.flipTextVertical()
            }
        }
   }

    // MARK: - Initializers
    required override public init () {
        super.init()
    }

}

extension FixedFilterStack: NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init()
        // swiftlint:disable force_cast
        copy.enhancementFilter = enhancementFilter.copyWithZone(zone) as! EnhancementFilter
        copy.orientationCropFilter = orientationCropFilter.copyWithZone(zone) as! OrientationCropFilter
        copy.effectFilter = effectFilter.copyWithZone(zone) as! EffectFilter
        copy.brightnessFilter = brightnessFilter.copyWithZone(zone) as! ContrastBrightnessSaturationFilter
        copy.tiltShiftFilter = tiltShiftFilter.copyWithZone(zone) as! TiltshiftFilter
        copy.borderFilter = borderFilter.copyWithZone(zone) as! BorderFilter
        copy.spriteFilters = NSArray(array: spriteFilters, copyItems: true) as! [Filter]
        // swiftlint:enable force_cast
        return copy
    }
}
