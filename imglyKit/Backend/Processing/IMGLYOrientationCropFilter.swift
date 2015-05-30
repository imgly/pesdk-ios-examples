//
//  IMGLYOrientationCropFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 20/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
import CoreImage
#elseif os(OSX)
import AppKit
import QuartzCore
#endif

/**
Represents the angle an image should be rotated by.
*/
@objc public enum IMGLYRotationAngle: Int {
    case _0
    case _90
    case _180
    case _270
}

/**
  Performes a rotation/flip operation and then a crop.
 Note that the result of the rotate/flip operation id transfered  to a temp CGImage.
 This is needed since otherwise the resulting CIImage has no no size due the lack of inforamtion within
 the CIImage.
*/
public class IMGLYOrientationCropFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    public var cropRect = CGRectMake(0, 0, 1, 1)
    public var rotationAngle = IMGLYRotationAngle._0
    
    private var flipVertical_ = false
    private var flipHorizontal_ = false
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imgly_displayName = "OrientationCropFilter"
    }
    
    override init() {
        super.init()
        self.imgly_displayName = "OrientationCropFilter"
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            var radiant = realNumberForRotationAngle(rotationAngle)
            var rotationTransformation = CGAffineTransformMakeRotation(radiant)
            var flipH:CGFloat = flipHorizontal_ ? -1 : 1
            var flipV:CGFloat = flipVertical_ ? -1 : 1
            var flipTransformation = CGAffineTransformScale(rotationTransformation, flipH, flipV)
            var filter = CIFilter(name: "CIAffineTransform")
            filter.setValue(inputImage!, forKey: kCIInputImageKey)
            
            #if os(iOS)
            let transform = NSValue(CGAffineTransform: flipTransformation)
            #elseif os(OSX)
            let transform = NSAffineTransform(CGAffineTransform: flipTransformation)
            #endif
            
            filter.setValue(transform, forKey: kCIInputTransformKey)
            var transformedImage = filter!.outputImage
            
            #if os(iOS)
            let context = CIContext(options: nil)
            #elseif os(OSX)
            let context = CIContext(CGContext: NSGraphicsContext.currentContext()?.CGContext, options: nil)
            #endif
            
            var tempCGImage = context.createCGImage(transformedImage!, fromRect: transformedImage!.extent())
            var tempCIImage = CIImage(CGImage: tempCGImage)
            var cropFilter = IMGLYCropFilter()
            cropFilter.cropRect = cropRect
            cropFilter.setValue(tempCIImage!, forKey: kCIInputImageKey)
            var croppedImage = cropFilter.outputImage
            return croppedImage
        }
    }
    
    private func realNumberForRotationAngle(rotationAngle: IMGLYRotationAngle) -> CGFloat {
        switch (rotationAngle) {
        case IMGLYRotationAngle._0:
             return 0
        case IMGLYRotationAngle._90:
            return CGFloat(M_PI_2)
        case IMGLYRotationAngle._180:
            return CGFloat(M_PI)
        case IMGLYRotationAngle._270:
            return CGFloat(M_PI_2 + M_PI)
        }
    }
    
    // MARK:- orientation modifier {
    /**
        Sets internal flags so that the filtered image will be rotated counter-clock-wise around 90 degrees.
    */
    public func rotateLeft() {
        switch (rotationAngle) {
        case IMGLYRotationAngle._0:
            rotationAngle = IMGLYRotationAngle._90
        case IMGLYRotationAngle._90:
            rotationAngle = IMGLYRotationAngle._180
        case IMGLYRotationAngle._180:
            rotationAngle = IMGLYRotationAngle._270
        case IMGLYRotationAngle._270:
            rotationAngle = IMGLYRotationAngle._0
        }
    }
        
    /**
        Sets internal flags so that the filtered image will be rotated clock-wise around 90 degrees.
    */
    public func rotateRight() {
        switch (self.rotationAngle) {
        case IMGLYRotationAngle._0:
            rotationAngle = IMGLYRotationAngle._270
        case IMGLYRotationAngle._90:
            rotationAngle = IMGLYRotationAngle._0
        case IMGLYRotationAngle._180:
            rotationAngle = IMGLYRotationAngle._90
        case IMGLYRotationAngle._270:
            rotationAngle = IMGLYRotationAngle._180
        }
    }

    /**
    Sets internal flags so that the filtered image will be rotated flipped along the horizontal axis.
    */
    public func flipHorizontal() {
        if (rotationAngle == IMGLYRotationAngle._0 || rotationAngle == IMGLYRotationAngle._180) {
            flipHorizontal_ = !flipHorizontal_
        } else {
            flipVertical_ = !flipVertical_
        }
    }
    
    /**
    Sets internal flags so that the filtered image will be rotated flipped along the vertical axis.
    */
    public func flipVertical() {
        if (rotationAngle == IMGLYRotationAngle._0 || rotationAngle == IMGLYRotationAngle._180) {
            flipVertical_ = !flipVertical_
        } else {
            flipHorizontal_ = !flipHorizontal_
        }
    }
}

extension IMGLYOrientationCropFilter: NSCopying {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYOrientationCropFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.cropRect = cropRect
        copy.rotationAngle = rotationAngle
        copy.flipVertical_ = flipVertical_
        copy.flipHorizontal_ = flipHorizontal_
        return copy
    }
}