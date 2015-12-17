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
        setCropRectForStickerFilters()
        setCropRectForTextFilters()
        var activeFilters: [CIFilter] = [enhancementFilter, orientationCropFilter, tiltShiftFilter, effectFilter, brightnessFilter, textFilter]
        activeFilters += stickerFilters
        return activeFilters
    }
    
    private func setCropRectForStickerFilters () {
        for stickerFilter in stickerFilters {
            (stickerFilter as! IMGLYStickerFilter).cropRect = orientationCropFilter.cropRect
        }
    }
    
    private func setCropRectForTextFilters () {
        //for stickerFilter in stickerFilters {
         //   (stickerFilter as! IMGLYStickerFilter).cropRect = orientationCropFilter.cropRect
        //}
        textFilter.cropRect = orientationCropFilter.cropRect
    }

    public func rotateStickersRight () {
        rotateStickers(CGFloat(M_PI_2), negateX: true, negateY: false)
    }

    public func rotateStickersLeft () {
        rotateStickers(CGFloat(-M_PI_2), negateX: false, negateY: true)
    }
    
    private func rotateStickers (angle:CGFloat, negateX:Bool ,negateY:Bool) {
        let xFactor:CGFloat = negateX ? -1.0 : 1.0
        let yFactor:CGFloat = negateY ? -1.0 : 1.0
        for filter in self.activeFilters {
            if let stickerFilter = filter as? IMGLYStickerFilter {
                stickerFilter.transform = CGAffineTransformRotate(stickerFilter.transform, angle)
                stickerFilter.center.x -= 0.5
                stickerFilter.center.y -= 0.5
                let center = stickerFilter.center
                stickerFilter.center.x = xFactor * center.y
                stickerFilter.center.y = yFactor * center.x
                stickerFilter.center.x += 0.5
                stickerFilter.center.y += 0.5
            }
        }
    }

    public func flipStickersHorizontal () {
        flipStickers(true)
    }

    public func flipStickersVertical () {
        flipStickers(false)
    }
    
    private func flipStickers(horizontal:Bool) {
        for filter in self.activeFilters {
            if let stickerFilter = filter as? IMGLYStickerFilter {
                if let sticker = stickerFilter.sticker {
                    let flippedOrientation = UIImageOrientation(rawValue:(sticker.imageOrientation.rawValue + 4) % 8)
                    stickerFilter.sticker = UIImage(CGImage: sticker.CGImage!, scale: sticker.scale, orientation: flippedOrientation!)
                }
                stickerFilter.center.x -= 0.5
                stickerFilter.center.y -= 0.5
                let center = stickerFilter.center
                if (horizontal) {
                    flipRotationHorizontal(stickerFilter)
                    stickerFilter.center.x = -center.x
                } else {
                    flipRotationVertical(stickerFilter)
                    stickerFilter.center.y = -center.y
                }
                stickerFilter.center.x += 0.5
                stickerFilter.center.y += 0.5
            }
        }
    }

    private func flipRotationHorizontal (stickerFilter:IMGLYStickerFilter) {
        flipRotation(stickerFilter, axisAngle: CGFloat(M_PI))
    }
    
    private func flipRotationVertical (stickerFilter:IMGLYStickerFilter) {
        flipRotation(stickerFilter, axisAngle: CGFloat(M_PI_2))
    }

    private func flipRotation (stickerFilter:IMGLYStickerFilter, axisAngle:CGFloat) {
        var angle = atan2(stickerFilter.transform.b, stickerFilter.transform.a)
        let twoPI = CGFloat(M_PI * 2.0)
        // normalize angle
        while (angle >= twoPI) {
            angle -= twoPI
        }
        while (angle < 0) {
            angle += twoPI
        }
        let delta = axisAngle - angle
        stickerFilter.transform = CGAffineTransformRotate(stickerFilter.transform, delta * 2.0)
    }

    // MARK: - Initializers
    required override public init () {
        super.init()
    }
    
}

extension IMGLYFixedFilterStack: NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init()
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
