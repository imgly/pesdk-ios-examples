//
//  SaturationBrightnessPickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYSaturationBrightnessPickerViewDelegate) public protocol SaturationBrightnessPickerViewDelegate {
    func colorPicked(saturationBrightnessPickerView: SaturationBrightnessPickerView, didPickColor color: UIColor)
}

@objc(IMGLYSaturationBrightnessPickerView) public class SaturationBrightnessPickerView: UIView {

    /// The receiver’s delegate.
    /// seealso: `SaturationBrightnessPickerViewDelegate`.
    public weak var pickerDelegate: SaturationBrightnessPickerViewDelegate?
    public var hue = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var color: UIColor {
        set {
            let hsb = newValue.hsb
            hue = hsb.hue
            brightness = hsb.brightness
            saturation = hsb.saturation
            setNeedsDisplay()
        }
        get {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        }
    }
    public var saturation = CGFloat(1)
    public var brightness = CGFloat(1)

    /**
     Initializes and returns a newly allocated view with the specified frame rectangle.

     - parameter frame: The frame rectangle for the view, measured in points.

     - returns: An initialized view object or `nil` if the object couldn't be created.
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        opaque = false
        backgroundColor = UIColor.clearColor()
    }

    override public func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorMatrixToContext(context, rect: rect)
            drawMarkerToContext(context, rect: rect)
        }
    }

    private func drawColorMatrixToContext(context: CGContextRef, rect: CGRect) {
        CGContextSaveGState(context)
        PathHelper.clipCornersToOvalWidth(context, width:frame.size.width, height: frame.size.height, ovalWidth:3.0, ovalHeight:3.0)
        CGContextClip(context)
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
    }

    private func drawMarkerToContext(context: CGContextRef, rect: CGRect) {
        let realPos = CGPoint(x: saturation * rect.size.width, y:rect.size.height - (brightness * rect.size.height))
        let reticuleRect = CGRect(x: realPos.x - 10, y: realPos.y - 10, width: 20, height: 20)

        CGContextAddEllipseInRect(context, reticuleRect)
        CGContextAddEllipseInRect(context, CGRectInset(reticuleRect, 4, 4))
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextClosePath(context)
        CGContextSetShadow(context, CGSize(width: 1.0, height: 1.0), 4)
        CGContextDrawPath(context, CGPathDrawingMode.EOFillStroke)
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
        var pos = touch.locationInView(self)

        let w = self.frame.size.width
        let h = self.frame.size.height

        pos.x = min(max(pos.x, 0), w)
        pos.y = min(max(pos.y, 0), h)

        saturation = pos.x / w
        brightness = 1 - (pos.y / h)

        pickerDelegate?.colorPicked(self,  didPickColor: UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0))

        self.setNeedsDisplay()
    }
}
