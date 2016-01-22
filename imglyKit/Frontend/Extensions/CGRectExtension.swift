//
//  CGRectExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

extension CGRect {
    init?(points: [CGPoint]) {
        var maxX: CGFloat?
        var maxY: CGFloat?
        var minX: CGFloat?
        var minY: CGFloat?

        for point in points {
            if let x = maxX {
                maxX = max(x, point.x)
            } else {
                maxX = point.x
            }

            if let y = maxY {
                maxY = max(y, point.y)
            } else {
                maxY = point.y
            }

            if let x = minX {
                minX = min(x, point.x)
            } else {
                minX = point.x
            }

            if let y = minY {
                minY = min(y, point.y)
            } else {
                minY = point.y
            }
        }

        if let maxX = maxX, maxY = maxY, minX = minX, minY = minY {
            origin = CGPoint(x: minX, y: minY)
            size = CGSize(width: maxX - minX, height: maxY - minY)
        } else {
            return nil
        }
    }

    mutating func fittedIntoTargetRect(targetRect: CGRect, withContentMode contentMode: UIViewContentMode) {
        if !(contentMode == .ScaleAspectFit || contentMode == .ScaleAspectFill) {
            // Not implemented
            return
        }

        var scale = targetRect.width / self.width

        if contentMode == .ScaleAspectFit {
            if self.height * scale > targetRect.height {
                scale = targetRect.height / self.height
            }
        } else if contentMode == .ScaleAspectFill {
            if self.height * scale < targetRect.height {
                scale = targetRect.height / self.height
            }
        }

        let scaledWidth = self.width * scale
        let scaledHeight = self.height * scale
        let scaledX = targetRect.width / 2 - scaledWidth / 2
        let scaledY = targetRect.height / 2 - scaledHeight / 2

        self.origin.x = scaledX
        self.origin.y = scaledY
        self.size.width = scaledWidth
        self.size.height = scaledHeight
    }

    func rectFittedIntoTargetRect(targetRect: CGRect, withContentMode contentMode: UIViewContentMode) -> CGRect {
        var sourceRect = self
        sourceRect.fittedIntoTargetRect(targetRect, withContentMode: contentMode)
        return sourceRect
    }
}
