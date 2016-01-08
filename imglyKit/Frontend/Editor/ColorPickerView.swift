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
    func colorPickerView(colorPickerView: ColorPickerView, didSelectColor color: UIColor)
}

@objc(IMGLYColorPickerView) public class ColorPickerView: UIView {
    public weak var pickerDelegate: ColorPickerViewDelegate?

    private var saturationBrightnessPickerView = SaturationBrightnessPickerView()

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
    }


    private func configureSaturationBrightnessPicker() {
        saturationBrightnessPickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(saturationBrightnessPickerView)

        let views = [
            "saturationBrightnessPickerView" : saturationBrightnessPickerView
        ]

        NSLayoutConstraint(item: saturationBrightnessPickerView, attribute: .Height, relatedBy: .Equal, toItem: saturationBrightnessPickerView, attribute: .Width, multiplier: 1, constant: 0).active = true

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[saturationBrightnessPickerView]-20-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[saturationBrightnessPickerView]", options: [], metrics: nil, views: views))
    }
}
