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
            updateMarkerPosition()
            self.setNeedsDisplay()
        }
    }

    /// The currently picked color.
    public var color: UIColor {
        set {
            let hsb = newValue.hsb
            hue = hsb.hue
            brightness = hsb.brightness
            saturation = hsb.saturation
            updateMarkerPosition()
            setNeedsDisplay()
        }
        get {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        }
    }

    /// The currently picked saturation.
    public var saturation = CGFloat(1)

    /// The currently picked brightness.
    public var brightness = CGFloat(1)

    private let markerView = UIView()

    /**
     :nodoc:
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    /**
     :nodoc:
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        opaque = false
        self.clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        configureMarkerView()
    }

    private func configureMarkerView() {
        markerView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        markerView.layer.borderColor = UIColor.whiteColor().CGColor
        markerView.layer.borderWidth = 2.0
        markerView.layer.cornerRadius = 18
        markerView.backgroundColor = UIColor.clearColor()
        markerView.layer.shadowColor = UIColor.blackColor().CGColor
        markerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        markerView.layer.shadowOpacity = 0.25
        markerView.layer.shadowRadius = 2
        markerView.center = CGPoint.zero
        self.addSubview(markerView)
    }

    override public func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawColorMatrixToContext(context, rect: rect)
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
        updateMarkerPosition()

        pickerDelegate?.colorPicked(self,  didPickColor: UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0))

        self.setNeedsDisplay()
    }

    private func updateMarkerPosition() {
        let realPos = CGPoint(x: saturation * self.frame.size.width, y: self.frame.size.height - (brightness * self.frame.size.height))
        markerView.center = realPos
    }
}
