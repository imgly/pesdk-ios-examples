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
    /// Returns a copy of the image, taking into account its orientation
    public var imgly_normalizedImage: UIImage {
        if imageOrientation == .Up {
            return self
        }

        return imgly_normalizedImageOfSize(size)
    }

    /**
    Returns a rescaled copy of the image, taking into account its orientation

    - parameter size: The size of the rescaled image.

    - returns: The rescaled image.

    :discussion: The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter.
    */
    public func imgly_normalizedImageOfSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}

extension UIImageOrientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case Up: return "Up"
        case Down: return "Down"
        case Left: return "Left"
        case Right: return "Right"
        case UpMirrored: return "UpMirrored"
        case DownMirrored: return "DownMirrored"
        case LeftMirrored: return "LeftMirrored"
        case RightMirrored: return "RightMirrored"
        }
    }
}
