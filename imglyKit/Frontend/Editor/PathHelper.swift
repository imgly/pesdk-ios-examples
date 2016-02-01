//
//  PathHelper.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYPathHelper)  public class PathHelper: NSObject {
    static public func clipCornersToOvalWidth(context: CGContextRef, width:CGFloat, height:CGFloat, ovalWidth: CGFloat, ovalHeight: CGFloat) {
        var fw = CGFloat(0)
        var fh = CGFloat(0)
        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        if ovalWidth == 0 || ovalHeight == 0 {
            CGContextAddRect(context, rect)
            return
        }
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextScaleCTM(context, ovalWidth, ovalHeight)
        fw = CGRectGetWidth(rect) / ovalWidth
        fh = CGRectGetHeight(rect) / ovalHeight
        CGContextMoveToPoint(context, fw, fh / 2)
        CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1)
        CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1)
        CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1)
        CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1)
        CGContextClosePath(context)
        CGContextRestoreGState(context)
    }

}
