//
//  AlphaPickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYAlphaPickerViewDelegate) public protocol AlphaPickerViewDelegate {
    func alphaPicked(alphaPickerView: AlphaPickerView, alpha: CGFloat)
}

@objc(IMGLYAlphaPickerView) public class AlphaPickerView: UIView {
    public weak var pickerDelegate: AlphaPickerViewDelegate?

    private private(set) lazy var checkboardColor: UIColor = {
        var color = UIColor.whiteColor()
        let bundle = NSBundle(forClass: AlphaPickerView.self)
        if let image = UIImage(named: "checkerboard", inBundle: bundle, compatibleWithTraitCollection: nil) {
            color = UIColor(patternImage: image)
        }
        return color
    }()

    public var alphaValue = CGFloat(0) {
        didSet {
            self.setNeedsDisplay()
        }
    }

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
            alphaValue = CGColorGetAlpha(color.CGColor)
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
        CGContextSetFillColorWithColor(context, checkboardColor.CGColor)
        CGContextFillRect(context, self.bounds)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locs: [CGFloat] = [0.00, 1.0]
        let colors = [UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor,
            UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 0.0).CGColor]
        let grad = CGGradientCreateWithColors(colorSpace, colors, locs)

        CGContextDrawLinearGradient(context, grad, CGPoint(x:rect.size.width, y: 0), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)
    }

    private func drawMarkerToContext(context: CGContextRef, rect: CGRect) {
        let pos = rect.size.width * alphaValue
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

        alphaValue = p / self.frame.size.width
        pickerDelegate?.alphaPicked(self, alpha: alphaValue)
        self.setNeedsDisplay()
    }
}
