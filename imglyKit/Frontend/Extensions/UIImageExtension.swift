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
    // swiftlint:disable variable_name
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

    **Discussion**

     The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter.
    */
    public func imgly_normalizedImageOfSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawInRect(CGRect(origin: CGPoint.zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }

    // swiftlint:enable variable_name

    public func resizableImageFrom9Patch(image: UIImage) -> UIImage {
        let ninePatchBounds = determinBounds()
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width - 1, height: self.size.height - 1), false, 0)
        image.drawInRect(CGRect(x: -1, y: -1, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let resizeableImage = newImage.resizableImageWithCapInsets(UIEdgeInsets(top: ninePatchBounds.0, left: ninePatchBounds.1, bottom: ninePatchBounds.2, right: ninePatchBounds.3))
        return resizeableImage
    }

    private func determinBounds() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let topBottom = determinTopAndBottom()
        let leftRight = determinLeftAndRight()
        return (topBottom.0, leftRight.0, topBottom.1, leftRight.1)
    }

    private func determinTopAndBottom() -> (CGFloat, CGFloat) {
        let pixels = leftRow()
        var top = CGFloat(-1.0)
        var bottom = CGFloat(-1.0)
        var foundTop = false

        for y in 0...Int(self.size.height - 1) {
            let color = pixels[y]
            if CGColorGetAlpha(color.CGColor) == 1.0 && !foundTop {
                top = CGFloat(y - 1)
                foundTop = true
                continue
            }
            if CGColorGetAlpha(color.CGColor) == 0.0 && foundTop {
                bottom = self.size.height - CGFloat(y + 1)
                break
            }
        }
        return (top, bottom)
    }

    private func determinLeftAndRight() -> (CGFloat, CGFloat) {
        let pixels = topRow()
        var foundLeft = false
        var left = CGFloat(-1)
        var right = CGFloat(-1)

        for x in 0...Int(self.size.width - 1) {
            let color = pixels[x]
            if CGColorGetAlpha(color.CGColor) == 1.0 && !foundLeft {
                left = CGFloat(x - 1)
                foundLeft = true
                continue
            }
            if CGColorGetAlpha(color.CGColor) == 0.0 && foundLeft {
                right = self.size.width - CGFloat(x + 1)
                break
            }
        }
        return (left, right)
    }

    private func topRow() -> [UIColor] {
        var colors = [UIColor]()
        var position = CGPoint.zero
        for x in 0...Int(self.size.width - 1) {
            position.x = CGFloat(x)
            let color = self.getPixelColor(position)
            colors.append(color)
        }
        return colors
    }

    private func leftRow() -> [UIColor] {
        var colors = [UIColor]()
        var position = CGPoint.zero
        for y in 0...Int(self.size.height - 1) {
            position.y = CGFloat(y)
            let color = self.getPixelColor(position)
            colors.append(color)
        }
        return colors
    }

    func getPixelColor(pos: CGPoint) -> UIColor {
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
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
