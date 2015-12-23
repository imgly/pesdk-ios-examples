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
    case Deg0
    case Deg90
    case Deg180
    case Deg270
}

/**
  Performes a rotation/flip operation and then a crop.
 Note that the result of the rotate/flip operation is transfered  to a temp CGImage.
 This is needed since otherwise the resulting CIImage has no no size due the lack of inforamtion within
 the CIImage.
*/
public class IMGLYOrientationCropFilter: CIFilter, FilterType {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?
    public var cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

    private var rotationAngle = IMGLYRotationAngle.Deg0
    private var flippedVertically = false
    private var flippedHorizontally = false

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        let radiant = realNumberForRotationAngle(rotationAngle)
        let rotationTransformation = CGAffineTransformMakeRotation(radiant)
        let flipH: CGFloat = flippedHorizontally ? -1 : 1
        let flipV: CGFloat = flippedVertically ? -1 : 1
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
        case IMGLYRotationAngle.Deg0:
             return 0
        case IMGLYRotationAngle.Deg90:
            return CGFloat(M_PI_2)
        case IMGLYRotationAngle.Deg180:
            return CGFloat(M_PI)
        case IMGLYRotationAngle.Deg270:
            return CGFloat(M_PI_2 + M_PI)
        }
    }

    // MARK:- orientation modifier {
    /**
        Sets internal flags so that the filtered image will be rotated counter-clock-wise around 90 degrees.
    */
    public func rotateLeft() {
        switch rotationAngle {
        case IMGLYRotationAngle.Deg0:
            rotationAngle = IMGLYRotationAngle.Deg90
        case IMGLYRotationAngle.Deg90:
            rotationAngle = IMGLYRotationAngle.Deg180
        case IMGLYRotationAngle.Deg180:
            rotationAngle = IMGLYRotationAngle.Deg270
        case IMGLYRotationAngle.Deg270:
            rotationAngle = IMGLYRotationAngle.Deg0
        }

        rotateCropRectLeft()
    }

    /**
        Sets internal flags so that the filtered image will be rotated clock-wise around 90 degrees.
    */
    public func rotateRight() {
        switch rotationAngle {
        case IMGLYRotationAngle.Deg0:
            rotationAngle = IMGLYRotationAngle.Deg270
        case IMGLYRotationAngle.Deg90:
            rotationAngle = IMGLYRotationAngle.Deg0
        case IMGLYRotationAngle.Deg180:
            rotationAngle = IMGLYRotationAngle.Deg90
        case IMGLYRotationAngle.Deg270:
            rotationAngle = IMGLYRotationAngle.Deg180
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
        if rotationAngle == IMGLYRotationAngle.Deg0 || rotationAngle == IMGLYRotationAngle.Deg180 {
            flippedHorizontally = !flippedHorizontally
        } else {
            flippedVertically = !flippedVertically
        }

        flipCropRectHorizontal()
    }

    /**
    Sets internal flags so that the filtered image will be rotated flipped along the vertical axis.
    */
    public func flipVertical() {
        if rotationAngle == IMGLYRotationAngle.Deg0 || rotationAngle == IMGLYRotationAngle.Deg180 {
            flippedVertically = !flippedVertically
        } else {
            flippedHorizontally = !flippedHorizontally
        }

        flipCropRectVertical()
    }
}

extension IMGLYOrientationCropFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! IMGLYOrientationCropFilter
        // swiftlint:enable force_cast
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.cropRect = cropRect
        copy.rotationAngle = rotationAngle
        copy.flippedVertically = flippedVertically
        copy.flippedHorizontally = flippedHorizontally
        return copy
    }
}
