//
//  TextFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
    import CoreImage
    import UIKit
#elseif os(OSX)
    import QuartzCore
    import AppKit
#endif

@objc(IMGLYTextFilter) public class TextFilter: CIFilter, Filter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?

    /// The text that should be rendered.
    public var text = ""

    /// The name of the used font.
    public var fontName = "Helvetica Neue"
    ///  This factor determins the font-size. Its a relative value that is multiplied with the image height
    ///  during the process.
    public var initialFontSize = CGFloat(1)

    public var transform = CGAffineTransformIdentity

    /// The relative center of the sticker within the image.
    public var center = CGPoint()

    /// The crop-create applied to the input image, so we can adjust the sticker position
    public var cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

    /// The color of the text.
    public var color = Color.whiteColor()

    /// The background-color of the text.
    public var backgroundColor = Color(white: 1.0, alpha: 0.0)

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }

        if text.isEmpty {
            return inputImage
        }

        guard let filter = CIFilter(name: "CISourceOverCompositing"), textImage = createCoreImage() else {
            return inputImage
        }

        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(textImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    private func createCoreImage() -> CIImage? {
        let textImage = createTextImage()
        var image: CIImage

        #if os(iOS)
            if let textImage = textImage.CGImage {
                image = CIImage(CGImage: textImage)
            } else {
                return nil
            }
        #elseif os(OSX)
            if let tiffRepresentation = textImage.TIFFRepresentation, textImage = CIImage(data: tiffRepresentation) {
                image = textImage
            } else {
                return nil
            }
        #endif

        let inputImageRect = inputImage!.extent
        let inputImageSize = inputImageRect.size

        let originalInputImageSize = CGSize(width: round(inputImageSize.width / cropRect.width), height: round(inputImageSize.height / cropRect.height))

        var textCenter = CGPoint(x: center.x * originalInputImageSize.width, y: center.y * originalInputImageSize.height)
        textCenter.x -= (cropRect.origin.x * originalInputImageSize.width)
        textCenter.y -= (cropRect.origin.y * originalInputImageSize.height)
        let textImageSize = image.extent.size

        let rotation = self.transform.rotation

        var transform = CGAffineTransformIdentity

        // Translate
        // Calculate the origin of the text image. Note that in CoreImage (0,0) is at the bottom
        let textImageOrigin = CGPoint(x: textCenter.x - textImageSize.width / 2, y: textCenter.y + textImageSize.height / 2)
        transform = CGAffineTransformTranslate(transform, textImageOrigin.x, inputImageSize.height - textImageOrigin.y)

        // Rotate
        transform = CGAffineTransformTranslate(transform, 0.5 * textImageSize.width, 0.5 * textImageSize.height)
        transform = CGAffineTransformRotate(transform, -1 * rotation)
        transform = CGAffineTransformTranslate(transform, -0.5 * textImageSize.width, -0.5 * textImageSize.height)

        image = image.imageByApplyingTransform(transform)
        image = image.imageByCroppingToRect(inputImageRect)

        return image
    }

    #if os(iOS)

    private func createTextImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size

        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))

        // swiftlint:disable force_cast
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        let textSize = textImageSize()
        UIGraphicsBeginImageContext(textSize)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        backgroundColor.setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: textSize))

        if let font = UIFont(name: fontName, size: initialFontSize * originalSize.height), paragraphStyle = customParagraphStyle.copy() as? NSParagraphStyle {
            text.drawAtPoint(CGPoint.zero, withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle])
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()

        return image
    }

    #elseif os(OSX)

    private func createTextImage() -> NSImage {
        let rect = inputImage!.extent
        let imageSize = rect.size

        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))

        // swiftlint:disable force_cast
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        let textSize = textImageSize()

        let image = NSImage(size: textSize)
        image.lockFocus()

        backgroundColor.setFill()
        NSRectFill(CGRect(origin: CGPoint(), size: textSize))

        if let font = NSFont(name: fontName, size: initialFontSize * originalSize.height), paragraphStyle = customParagraphStyle.copy() as? NSParagraphStyle {
            text.drawAtPoint(CGPoint.zero, withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle])
        }

        image.unlockFocus()

        return image
    }

    #endif

    private func textImageSize() -> CGSize {
        let rect = inputImage!.extent
        let imageSize = rect.size

        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        // swiftlint:disable force_cast
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        guard let font = Font(name: fontName, size: initialFontSize * originalSize.height), paragraphStyle = customParagraphStyle.copy() as? NSParagraphStyle else {
            return CGSize.zero
        }
        return text.sizeWithAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle])
    }

    public func textImageSizeFromImageSize(imageSize: CGSize) -> CGSize {
        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        // swiftlint:disable force_cast
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        guard let font = Font(name: fontName, size: initialFontSize * originalSize.height), paragraphStyle = customParagraphStyle.copy() as? NSParagraphStyle else {
            return CGSize.zero
        }
        return text.sizeWithAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle])
    }

    // MARK: - Rotation

    public func rotateTextRight () {
        if self.inputImage != nil {
            rotateText(CGFloat(M_PI_2), negateX: true, negateY: false)
        }
    }

    public func rotateTextLeft () {
        if self.inputImage != nil {
            rotateText(CGFloat(-M_PI_2), negateX: false, negateY: true)
        }
    }

    private func rotateText (angle: CGFloat, negateX: Bool, negateY: Bool) {
        let xFactor: CGFloat = negateX ? -1.0 : 1.0
        let yFactor: CGFloat = negateY ? -1.0 : 1.0
        self.transform = CGAffineTransformRotate(self.transform, angle)
        self.center.x -= 0.5
        self.center.y -= 0.5
        let ratio = self.inputImage!.extent.size.height / self.inputImage!.extent.size.width
        self.initialFontSize *= ratio
        let center = self.center
        self.center.x = xFactor * center.y
        self.center.y = yFactor * center.x
        self.center.x += 0.5
        self.center.y += 0.5
    }

    // MARK: - Flipping

    public func flipTextHorizontal () {
        flipText(true)
    }

    public func flipTextVertical () {
        flipText(false)
    }

    private func flipText(horizontal: Bool) {
        self.center.x -= 0.5
        self.center.y -= 0.5
        let center = self.center

        if horizontal {
            flipRotationHorizontal()
            self.center.x = -center.x
        } else {
            flipRotationVertical()
            self.center.y = -center.y
        }

        self.center.x += 0.5
        self.center.y += 0.5
    }

    private func flipRotationHorizontal() {
        flipRotation(CGFloat(M_PI))
    }

    private func flipRotationVertical() {
        flipRotation(CGFloat(M_PI_2))
    }

    /**
     In this method we perform the mirroring around an Axis.
     The Axis is defined by its angle.
     To calculate the final angle, we mirror the angle around the axis
     and add that delta to the current rotation.

     - parameter axisAngle: The angle that defins the axis that is used for mirroring the angle.
     */
    private func flipRotation(axisAngle: CGFloat) {
        var angle = atan2(self.transform.b, self.transform.a)
        let twoPI = CGFloat(M_PI * 2.0)
        // normalize angle
        while angle >= twoPI {
            angle -= twoPI
        }

        while angle < 0 {
            angle += twoPI
        }

        let delta = axisAngle - angle
        self.transform = CGAffineTransformRotate(self.transform, delta * 2.0)
    }
}

extension TextFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        // swiftlint:disable force_cast
        let copy = super.copyWithZone(zone) as! TextFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.text = (text as NSString).copyWithZone(zone) as! String
        copy.fontName = (fontName as NSString).copyWithZone(zone) as! String
        copy.initialFontSize = initialFontSize
        copy.cropRect = cropRect
        copy.center = center
        copy.transform = transform
        copy.color = color.copyWithZone(zone) as! Color
        copy.backgroundColor = backgroundColor.copyWithZone(zone) as! Color
        // swiftlint:enable force_cast
        return copy
    }
}
