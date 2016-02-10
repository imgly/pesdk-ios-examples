//
//  ColorPickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 07/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//
//  based on https://github.com/jawngee/ILColorPicker

import UIKit

/**
 The `IMGLYColorPickerViewDelegate` protocol defines a set of optional methods you can use to receive value-change messages for ColorPickerViewDelegate objects.
 */
@objc(IMGLYColorPickerViewDelegate) public protocol ColorPickerViewDelegate {
    /**
     Is called when a color has been picked.

     - parameter colorPickerView: The sender of the event.
     - parameter color:           The picked color value.
     */
    func colorPicked(colorPickerView: ColorPickerView, didPickColor color: UIColor)
    /**
     Is called when the picking process has been cancled.

     - parameter colorPickerView: The sender of the event.
     */
    func canceledColorPicking(colorPickerView: ColorPickerView)
}

/**
 The `ColorPickerView` class provides a class that is used to pick colors. 
 It contains three elements. A hue-picker, a brightness-saturation-picker and a preview of the picked color.
 */
@objc(IMGLYColorPickerView) public class ColorPickerView: UIView {

    /// The receiver’s delegate.
    /// seealso: `ColorPickerViewDelegate`.
    public weak var pickerDelegate: ColorPickerViewDelegate?

    /// The currently selected color.
    public var color = UIColor.blackColor() {
        didSet {
            huePickerView.color = color
            alphaPickerView.color = color
            colorView.backgroundColor = color.colorWithAlphaComponent(alphaPickerView.alphaValue)
            saturationBrightnessPickerView.color = color
        }
    }

    /// The initial set color.
    public var initialColor = UIColor.blackColor() {
        didSet {
            color = initialColor
        }
    }

    private var colorView = UIView()
    private var saturationBrightnessPickerView = SaturationBrightnessPickerView()
    private var huePickerView = HuePickerView()
    private var alphaPickerView = AlphaPickerView()

    // MARK: - init

    /**
    Initializes and returns a newly allocated view with the specified frame rectangle.

    - parameter frame: The frame rectangle for the view, measured in points.

    - returns: An initialized view object or `nil` if the object couldn't be created.
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
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
        configureSaturationBrightnessPicker()
        configureColorView()
        configureHuePickView()
        configureAlphaPickerView()
        configureConstraints()
    }

    // MARK: - configuration

    private func configureSaturationBrightnessPicker() {
        self.addSubview(saturationBrightnessPickerView)
        saturationBrightnessPickerView.translatesAutoresizingMaskIntoConstraints = false
        saturationBrightnessPickerView.pickerDelegate = self
    }

    private func configureColorView() {
        self.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 3
    }

    private func configureHuePickView() {
        self.addSubview(huePickerView)
        huePickerView.translatesAutoresizingMaskIntoConstraints = false
        huePickerView.pickerDelegate = self
    }

    private func configureAlphaPickerView() {
        self.addSubview(alphaPickerView)
        alphaPickerView.translatesAutoresizingMaskIntoConstraints = false
        alphaPickerView.pickerDelegate = self
    }

    private func configureConstraints() {
        let views = [
            "colorView" : colorView,
            "saturationBrightnessPickerView" : saturationBrightnessPickerView,
            "huePickerView" : huePickerView,
            "alphaPickerView" : alphaPickerView
        ]

        NSLayoutConstraint(item: saturationBrightnessPickerView, attribute: .Height, relatedBy: .Equal, toItem: saturationBrightnessPickerView, attribute: .Width, multiplier: 1, constant: 0).active = true

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[alphaPickerView(==20)]-15-[saturationBrightnessPickerView]-15-[huePickerView(==20)]-15-[colorView(>=20)]-(110@750)-|", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[saturationBrightnessPickerView]-20-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[colorView]-20-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[huePickerView]-20-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[alphaPickerView]-20-|", options: [], metrics: nil, views: views))
    }
}

extension ColorPickerView: SaturationBrightnessPickerViewDelegate {
    /**
     :nodoc:
     */
    public func colorPicked(saturationBrightnessPickerView: SaturationBrightnessPickerView, didPickColor color: UIColor) {
        colorView.backgroundColor = color.colorWithAlphaComponent(alphaPickerView.alphaValue)
        pickerDelegate?.colorPicked(self, didPickColor: colorView.backgroundColor!)
    }
}

extension ColorPickerView: HuePickerViewDelegate {
    /**
     :nodoc:
     */
    public func huePicked(huePickerView: HuePickerView, hue: CGFloat) {
        saturationBrightnessPickerView.hue = hue
        alphaPickerView.hue = hue
        colorView.backgroundColor = saturationBrightnessPickerView.color.colorWithAlphaComponent(alphaPickerView.alphaValue)
        pickerDelegate?.colorPicked(self, didPickColor: colorView.backgroundColor!)
    }
}

extension ColorPickerView: AlphaPickerViewDelegate {
    /**
     :nodoc:
     */
    public func alphaPicked(alphaPickerView: AlphaPickerView, alpha: CGFloat) {
        let color = saturationBrightnessPickerView.color
        colorView.backgroundColor = color.colorWithAlphaComponent(alpha)
        pickerDelegate?.colorPicked(self, didPickColor: colorView.backgroundColor!)
    }
}
