//
//  HuePickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 *  The `HuePickerViewDelegate` will be used to broadcast changes of the picked hue.
 */
@objc(IMGLYHuePickerViewDelegate) public protocol HuePickerViewDelegate {
    func huePicked(huePickerView: HuePickerView, hue: CGFloat)
}


/**
 *  The `HuePickerView` class provides a view to visualy pick a hue.
 */
@objc(IMGLYHuePickerView) public class HuePickerView: UIView {

    /// The receiver’s delegate.
    /// seealso: `HuePickerViewDelegate`.
    public weak var pickerDelegate: HuePickerViewDelegate?

    private let markerView = UIView(frame: CGRect(x: -10, y: 0, width: 40, height: 4))

    /// The currently selected hue.
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
        markerView.backgroundColor = UIColor.whiteColor()
        markerView.layer.shadowColor = UIColor.blackColor().CGColor
        markerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        markerView.layer.shadowOpacity = 0.25
        markerView.layer.shadowRadius = 2
        self.addSubview(markerView)
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
        self.clipsToBounds = false
    }

    public var color = UIColor.redColor() {
        didSet {
            hue = color.hsb.hue
            self.setNeedsDisplay()
        }
    }

    /**
     :nodoc:
     */
    public override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorSpectrum(context, rect:rect)
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
        CGContextDrawLinearGradient(context, grad, CGPoint(x: 0, y: rect.size.height), CGPoint(x: 0, y: 0), CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)
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
        let markerY = min(max(pos.y, 0), self.frame.size.height - markerView.frame.height)
        markerView.frame.origin = CGPoint(x: -10, y: markerY)

        let p = min(max(pos.y, 0), self.frame.size.height)
        hue = p / self.frame.size.height
        pickerDelegate?.huePicked(self, hue: hue)
        self.setNeedsDisplay()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        markerView.frame = CGRect(x: -frame.width / 2, y: 0, width: frame.width * 2, height: 4)
    }
}
