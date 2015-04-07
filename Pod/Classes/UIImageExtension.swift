//
//  UIImageExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import CoreGraphics

/**
Adds framework-related methods to `UIImage`.
*/
public extension UIImage {
    /**
    Returns a rescaled copy of the image, taking into account its orientation
    
    :param: size                 The size of the rescaled image.
    :param: interpolationQuality The quality of the rescaled image.
    
    :returns: The rescaled image.
    
    :discussion: The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter.
    */
    public func imageResizedToSize(size: CGSize, withInterpolationQuality interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let drawTransposed: Bool
        
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        case .Down, .DownMirrored, .Up, .UpMirrored:
            drawTransposed = false
        }
        
        let transform = transformForCurrentOrientationTranslatedToSize(size)
        
        return imageResizedToSize(size, withTransform: transform, drawTransposed: drawTransposed, interpolationQuality: interpolationQuality)
    }
    
    public var imageRotatedToMatchOrientation: UIImage {
        let imageWidth = CGImageGetWidth(self.CGImage)
        let imageHeight = CGImageGetHeight(self.CGImage)
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        
        var bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let scaleRatio = bounds.size.width / CGFloat(imageWidth)
        let boundHeight: CGFloat
        
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Up:
            transform = CGAffineTransformIdentity
        case .UpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
        case .Down:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .DownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
        case .LeftMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI_2))
        case .Left:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI_2))
        case .RightMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        if imageOrientation == .Right || imageOrientation == .Left {
            CGContextScaleCTM(context, -scaleRatio, scaleRatio)
            CGContextTranslateCTM(context, CGFloat(-imageHeight), 0)
        } else {
            CGContextScaleCTM(context, scaleRatio, -scaleRatio)
            CGContextTranslateCTM(context, 0, CGFloat(-imageHeight))
        }
        
        CGContextConcatCTM(context, transform)
        
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight), self.CGImage)
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageCopy
    }
    
    private func transformForCurrentOrientationTranslatedToSize(size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default:
            break
        }
        
        switch imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        
        return transform
    }
    
    private func imageResizedToSize(size: CGSize, withTransform transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let newRect = CGRectIntegral(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
        let image = self.CGImage
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmap = CGBitmapContextCreate(nil, Int(newRect.size.width), Int(newRect.size.height), CGImageGetBitsPerComponent(image), 0, rgbColorSpace, CGImageGetBitmapInfo(image))
        
        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform)
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, interpolationQuality)
        // Draw into the context; this scales the image
        CGContextDrawImage(bitmap, drawTransposed ? transposedRect : newRect, image)
        // Get the resized image from the context and a UIImage
        let newCGImage = CGBitmapContextCreateImage(bitmap)
        let newImage = UIImage(CGImage: newCGImage)
        
        return newImage
    }
}
