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
 Note that the result of the rotate/flip operation is transfered  to a temp CGImage.
 This is needed since otherwise the resulting CIImage has no no size due the lack of inforamtion within
 the CIImage.
*/
public class IMGLYOrientationCropFilter: CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?
    public var cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

    private var rotationAngle = IMGLYRotationAngle._0
    private var flipVertical_ = false
    private var flipHorizontal_ = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imgly_displayName = "OrientationCropFilter"
    }

    override init() {
        super.init()
        self.imgly_displayName = "OrientationCropFilter"
    }

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        let radiant = realNumberForRotationAngle(rotationAngle)
        let rotationTransformation = CGAffineTransformMakeRotation(radiant)
        let flipH: CGFloat = flipHorizontal_ ? -1 : 1
        let flipV: CGFloat = flipVertical_ ? -1 : 1
        var flipTransformation = CGAffineTransformScale(rotationTransformation, flipH, flipV)

        guard let filter = CIFilter(name: "CIAffineTransform") else {
            return inputImage
        }

        filter.setValue(inputImage, forKey: kCIInputImageKey)

        if let orientation = inputImage.properties["Orientation"] as? NSNumber {
            // Rotate image to match image orientation before cropping
            let transform = inputImage.imageTransformForOrientation(orientation.intValue)
            flipTransformation = CGAffineTransformConcat(flipTransformation, transform)
        }

        #if os(iOS)
            let transform = NSValue(CGAffineTransform: flipTransformation)
            #elseif os(OSX)
            let transform = NSAffineTransform(CGAffineTransform: flipTransformation)
        #endif

        filter.setValue(transform, forKey: kCIInputTransformKey)
        var outputImage = filter.outputImage

        let cropFilter = IMGLYCropFilter()
        cropFilter.cropRect = cropRect
        cropFilter.setValue(outputImage, forKey: kCIInputImageKey)
        outputImage = cropFilter.outputImage

        if let orientation = inputImage.properties["Orientation"] as? NSNumber {
            // Rotate image back to match metadata
            let invertedTransform = CGAffineTransformInvert(inputImage.imageTransformForOrientation(orientation.intValue))

            guard let filter = CIFilter(name: "CIAffineTransform") else {
                return outputImage
            }

            #if os(iOS)
                let transform = NSValue(CGAffineTransform: invertedTransform)
                #elseif os(OSX)
                let transform = NSAffineTransform(CGAffineTransform: invertedTransform)
            #endif

            filter.setValue(transform, forKey: kCIInputTransformKey)
            filter.setValue(outputImage, forKey: kCIInputImageKey)
            outputImage = filter.outputImage
        }

        return outputImage
    }

    private func realNumberForRotationAngle(rotationAngle: IMGLYRotationAngle) -> CGFloat {
        switch rotationAngle {
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
        switch rotationAngle {
        case IMGLYRotationAngle._0:
            rotationAngle = IMGLYRotationAngle._90
        case IMGLYRotationAngle._90:
            rotationAngle = IMGLYRotationAngle._180
        case IMGLYRotationAngle._180:
            rotationAngle = IMGLYRotationAngle._270
        case IMGLYRotationAngle._270:
            rotationAngle = IMGLYRotationAngle._0
        }
        rotateCropRectLeft()
    }

    /**
        Sets internal flags so that the filtered image will be rotated clock-wise around 90 degrees.
    */
    public func rotateRight() {
        switch rotationAngle {
        case IMGLYRotationAngle._0:
            rotationAngle = IMGLYRotationAngle._270
        case IMGLYRotationAngle._90:
            rotationAngle = IMGLYRotationAngle._0
        case IMGLYRotationAngle._180:
            rotationAngle = IMGLYRotationAngle._90
        case IMGLYRotationAngle._270:
            rotationAngle = IMGLYRotationAngle._180
        }
        rotateCropRectRight()
    }

    private func rotateCropRectLeft() {
        moveCropRectMidToOrigin()
        let tempRect = self.cropRect
        self.cropRect.origin.x = tempRect.origin.y
        self.cropRect.origin.y = -tempRect.origin.x
        self.cropRect.size.width = tempRect.size.height
        self.cropRect.size.height = -tempRect.size.width
        moveCropRectTopLeftToOrigin()
        sanitizeCropRect()
    }

    private func rotateCropRectRight() {
        moveCropRectMidToOrigin()
        let tempRect = cropRect
        cropRect.origin.x = -tempRect.origin.y
        cropRect.origin.y = tempRect.origin.x
        cropRect.size.width = -tempRect.size.height
        cropRect.size.height = tempRect.size.width
        moveCropRectTopLeftToOrigin()
        sanitizeCropRect()
    }

    private func flipCropRectHorizontal() {
        moveCropRectMidToOrigin()
        cropRect.origin.x = -self.cropRect.origin.x - self.cropRect.size.width
        moveCropRectTopLeftToOrigin()
        sanitizeCropRect()
    }

    private func flipCropRectVertical() {
        moveCropRectMidToOrigin()
        cropRect.origin.y = -self.cropRect.origin.y - self.cropRect.size.height
        moveCropRectTopLeftToOrigin()
        sanitizeCropRect()
    }

    private func moveCropRectMidToOrigin() {
        cropRect.origin.x -= 0.5
        cropRect.origin.y -= 0.5
    }

    private func moveCropRectTopLeftToOrigin() {
        cropRect.origin.x += 0.5
        cropRect.origin.y += 0.5
    }

    private func sanitizeCropRect () {
        if cropRect.size.width < 0.0 {
            cropRect.size.width *= -1.0
            cropRect.origin.x = cropRect.origin.x - cropRect.width
        }

        if cropRect.size.height < 0.0 {
            cropRect.size.height *= -1.0
            cropRect.origin.y = cropRect.origin.y - cropRect.height
        }
    }

    /**
    Sets internal flags so that the filtered image will be rotated flipped along the horizontal axis.
    */
    public func flipHorizontal() {
        if rotationAngle == IMGLYRotationAngle._0 || rotationAngle == IMGLYRotationAngle._180 {
            flipHorizontal_ = !flipHorizontal_
        } else {
            flipVertical_ = !flipVertical_
        }
        flipCropRectHorizontal()
    }

    /**
    Sets internal flags so that the filtered image will be rotated flipped along the vertical axis.
    */
    public func flipVertical() {
        if rotationAngle == IMGLYRotationAngle._0 || rotationAngle == IMGLYRotationAngle._180 {
            flipVertical_ = !flipVertical_
        } else {
            flipHorizontal_ = !flipHorizontal_
        }
        flipCropRectVertical()
    }
}

extension IMGLYOrientationCropFilter {
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
