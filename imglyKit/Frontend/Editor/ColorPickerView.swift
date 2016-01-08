//
//  ColorPickerView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 07/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//
//  based on https://github.com/jawngee/ILColorPicker

import UIKit

@objc(IMGLYColorPickerViewDelegate) public protocol ColorPickerViewDelegate {
    func colorPicked(colorPickerView: ColorPickerView, didPickColor color: UIColor)
}

@objc(IMGLYColorPickerView) public class ColorPickerView: UIView {
    public weak var pickerDelegate: ColorPickerViewDelegate?
    public var color = UIColor.blackColor() {
        didSet {
            huePickerView.color = color
            colorView.backgroundColor = color
        }
    }

    private var colorView = UIView()
    private var saturationBrightnessPickerView = SaturationBrightnessPickerView()
    private var huePickerView = HuePickerView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        configureSaturationBrightnessPicker()
        configureColorView()
        configureHuePickView()
        configureConstraints()
    }

    private func configureSaturationBrightnessPicker() {
        self.addSubview(saturationBrightnessPickerView)
        saturationBrightnessPickerView.translatesAutoresizingMaskIntoConstraints = false
        saturationBrightnessPickerView.pickerDelegate = self
    }

    private func configureColorView() {
        self.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.backgroundColor = UIColor.whiteColor()
    }

    private func configureHuePickView() {
        self.addSubview(huePickerView)
        huePickerView.translatesAutoresizingMaskIntoConstraints = false
        huePickerView.pickerDelegate = self
    }

    private func configureConstraints() {
        let views = [
            "colorView" : colorView,
            "saturationBrightnessPickerView" : saturationBrightnessPickerView,
            "huePickerView" : huePickerView
        ]

        NSLayoutConstraint(item: saturationBrightnessPickerView, attribute: .Height, relatedBy: .Equal, toItem: saturationBrightnessPickerView, attribute: .Width, multiplier: 1, constant: 0).active = true

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[saturationBrightnessPickerView]-20-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[colorView]-20-[saturationBrightnessPickerView]-20-[huePickerView]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[colorView]-20-|", options: [], metrics: nil, views: views))
        colorView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[colorView(==40)]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[huePickerView]-20-|", options: [], metrics: nil, views: views))
        huePickerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[huePickerView(==40)]", options: [], metrics: nil, views: views))
    }
}

extension ColorPickerView: SaturationBrightnessPickerViewDelegate {
    public func colorPicked(saturationBrightnessPickerView: SaturationBrightnessPickerView, didPickColor color: UIColor) {
        colorView.backgroundColor = color
    }
}

extension ColorPickerView: HuePickerViewDelegate {
    public func huePicked(huePickerView: HuePickerView, hue: CGFloat) {
        saturationBrightnessPickerView.hue = hue
        colorView.backgroundColor = saturationBrightnessPickerView.color
    }
}
