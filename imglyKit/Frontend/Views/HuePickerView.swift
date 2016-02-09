//
//  HuePickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYHuePickerViewDelegate) public protocol HuePickerViewDelegate {
    func huePicked(huePickerView: HuePickerView, hue: CGFloat)
}

@objc(IMGLYHuePickerView) public class HuePickerView: UIView {
    public weak var pickerDelegate: HuePickerViewDelegate?

    public var hue = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /**
     Initializes and returns a newly allocated view with the specified frame rectangle.

     - parameter frame: The frame rectangle for the view, measured in points.

     - returns: An initialized view object or `nil` if the object couldn't be created.
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        opaque = false
        backgroundColor = UIColor.clearColor()
    }

    public var color = UIColor.redColor() {
        didSet {
            hue = color.hsb.hue
            self.setNeedsDisplay()
        }
    }

    public override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorSpectrum(context, rect:rect)
            drawMarkerToContext(context, rect:rect)
        }
    }

    private func drawColorSpectrum(context: CGContextRef, rect: CGRect) {
        CGContextSaveGState(context)
        PathHelper.clipCornersToOvalWidth(context, width:frame.size.width, height: frame.size.height, ovalWidth:3.0, ovalHeight:3.0)
        CGContextClip(context)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let step = CGFloat(0.166666666666667)
        let locs: [CGFloat] = [0.00, step, step * 2, step * 3, step * 4, step * 5, 1.0]
        let colors = [UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0).CGColor,
            UIColor(red:1.0, green:0.0, blue:1.0, alpha:1.0).CGColor,
            UIColor(red:0.0, green:0.0, blue:1.0, alpha:1.0).CGColor,
            UIColor(red:0.0, green:1.0, blue:1.0, alpha:1.0).CGColor,
            UIColor(red:0.0, green:1.0, blue:0.0, alpha:1.0).CGColor,
            UIColor(red:1.0, green:1.0, blue:0.0, alpha:1.0).CGColor,
            UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0).CGColor]

        let grad = CGGradientCreateWithColors(colorSpace, colors, locs)

        CGContextDrawLinearGradient(context, grad, CGPoint(x: rect.size.width, y: 0), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)
    }

    private func drawMarkerToContext(context: CGContextRef, rect: CGRect) {
        let pos = rect.size.width * hue
        let indLength = rect.size.height / 3

        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextSetShadow(context, CGSize(width: 0, height: 0), 4)

        CGContextMoveToPoint(context, pos - (indLength / 2), -1)
        CGContextAddLineToPoint(context, pos + (indLength / 2), -1)
        CGContextAddLineToPoint(context, pos, indLength)
        CGContextAddLineToPoint(context, pos - (indLength / 2), -1)

        CGContextMoveToPoint(context, pos-(indLength / 2), rect.size.height + 1)
        CGContextAddLineToPoint(context, pos + (indLength / 2), rect.size.height + 1)
        CGContextAddLineToPoint(context, pos, rect.size.height-indLength)
        CGContextAddLineToPoint(context, pos - (indLength / 2), rect.size.height + 1)

        CGContextClosePath(context)
        CGContextDrawPath(context, .FillStroke)
    }

    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }

    private func handleTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let pos = touch.locationInView(self)
        let p = min(max(pos.x, 0), self.frame.size.width)

        hue = p / self.frame.size.width

        pickerDelegate?.huePicked(self, hue: hue)

        self.setNeedsDisplay()
    }
}
