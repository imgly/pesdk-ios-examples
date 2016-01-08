//
//  SaturationBrightnessPickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

//class SaturationBrightnessPickerView: UIView {
@objc(IMGLYSaturationBrightnessPickerView) public class SaturationBrightnessPickerView: UIView {
    public var hue = CGFloat(0.5)
    public var saturation = CGFloat(0.5)
    public var brightness = CGFloat(0.5)

    public override init(frame: CGRect) {
        super.init(frame:frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)
        CGContextClipToRect(context, rect)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let locs: [CGFloat] = [0.00, 1.0]

        var colors = [UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor,
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor]

        var grad = CGGradientCreateWithColors(colorSpace, colors, locs)
        CGContextDrawLinearGradient(context, grad, CGPoint(x:rect.size.width, y: 0), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))

        colors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor]

        grad = CGGradientCreateWithColors(colorSpace, colors, locs)
        CGContextDrawLinearGradient(context, grad, CGPoint(x: 0, y: 0), CGPoint(x: 0, y: rect.size.height), CGGradientDrawingOptions(rawValue: 0))

        CGContextRestoreGState(context)

        // draw the 'marker'

        let realPos = CGPoint(x: saturation * rect.size.width, y:rect.size.height - (brightness * rect.size.height))
        let reticuleRect = CGRect(x: realPos.x - 10, y: realPos.y - 10, width: 20, height: 20)

        CGContextAddEllipseInRect(context, reticuleRect)
        CGContextAddEllipseInRect(context, CGRectInset(reticuleRect, 4, 4))
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextClosePath(context)
        CGContextSetShadow(context, CGSize(width: 1.0, height: 1.0), 4)
        CGContextDrawPath(context, CGPathDrawingMode.EOFillStroke)
    }
}
