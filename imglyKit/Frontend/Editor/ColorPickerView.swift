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
    func canceledColorPicking(colorPickerView: ColorPickerView)
}

@objc(IMGLYColorPickerView) public class ColorPickerView: UIView {
    public weak var pickerDelegate: ColorPickerViewDelegate?
    public var color = UIColor.blackColor() {
        didSet {
            huePickerView.color = color
            alphaPickerView.color = color
            colorView.backgroundColor = color.colorWithAlphaComponent(alphaPickerView.alphaValue)
            saturationBrightnessPickerView.color = color
        }
    }

    public var initialColor = UIColor.blackColor() {
        didSet {
            color = initialColor
        }
    }

    private var colorView = UIView()
    private var saturationBrightnessPickerView = SaturationBrightnessPickerView()
    private var huePickerView = HuePickerView()
    private var alphaPickerView = AlphaPickerView()
    private var okButton = UIButton(type: .Custom)
    private var cancelButton = UIButton(type: .Custom)

    // MARK:- init

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
        configureAlphaPickerView()
        configureOkButton()
        configureCancelButton()
        configureConstraints()
    }

    // MARK:- configuration

    private func configureSaturationBrightnessPicker() {
        self.addSubview(saturationBrightnessPickerView)
        saturationBrightnessPickerView.translatesAutoresizingMaskIntoConstraints = false
        saturationBrightnessPickerView.pickerDelegate = self
    }

    private func configureColorView() {
        self.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
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

    private func configureOkButton() {
        self.addSubview(okButton)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        let bundle = NSBundle(forClass: ColorPickerView.self)
        let title = NSLocalizedString("color-picker-view-ok-button.title", tableName: nil, bundle: bundle, value: "", comment: "")
        okButton.setTitle(title, forState:UIControlState.Normal)
        okButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        okButton.addTarget(self, action: "okButtonTouched:", forControlEvents: .TouchUpInside)
    }

    private func configureCancelButton() {
        self.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let bundle = NSBundle(forClass: ColorPickerView.self)
        let title = NSLocalizedString("color-picker-view-cancel-button.title", tableName: nil, bundle: bundle, value: "", comment: "")
        cancelButton.setTitle(title, forState:UIControlState.Normal)
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        cancelButton.addTarget(self, action: "cancelButtonTouched:", forControlEvents: .TouchUpInside)
    }

    private func configureConstraints() {
        let views = [
            "colorView" : colorView,
            "saturationBrightnessPickerView" : saturationBrightnessPickerView,
            "huePickerView" : huePickerView,
            "alphaPickerView" : alphaPickerView,
            "cancelButton" : cancelButton,
            "okButton" : okButton
        ]

        NSLayoutConstraint(item: saturationBrightnessPickerView, attribute: .Height, relatedBy: .Equal, toItem: saturationBrightnessPickerView, attribute: .Width, multiplier: 1, constant: 0).active = true

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[saturationBrightnessPickerView]-20-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[colorView]-20-[saturationBrightnessPickerView]-20-[huePickerView]-20-[alphaPickerView]-20-[okButton]-[cancelButton]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[colorView]-20-|", options: [], metrics: nil, views: views))
        colorView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[colorView(==40)]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[huePickerView]-20-|", options: [], metrics: nil, views: views))
        huePickerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[huePickerView(==40)]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[alphaPickerView]-20-|", options: [], metrics: nil, views: views))
        alphaPickerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[alphaPickerView(==40)]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[okButton]-20-|", options: [], metrics: nil, views: views))
        okButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[okButton(==40)]", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[cancelButton]-20-|", options: [], metrics: nil, views: views))
        cancelButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[cancelButton(==40)]", options: [], metrics: nil, views: views))
    }

    // MARK:- actions
    public func okButtonTouched(sender: UIButton?) {
        pickerDelegate?.colorPicked(self, didPickColor: colorView.backgroundColor!)
    }

    public func cancelButtonTouched(sender: UIButton?) {
        pickerDelegate?.canceledColorPicking(self)
    }
}

extension ColorPickerView: SaturationBrightnessPickerViewDelegate {
    public func colorPicked(saturationBrightnessPickerView: SaturationBrightnessPickerView, didPickColor color: UIColor) {
        colorView.backgroundColor = color.colorWithAlphaComponent(alphaPickerView.alphaValue)
    }
}

extension ColorPickerView: HuePickerViewDelegate {
    public func huePicked(huePickerView: HuePickerView, hue: CGFloat) {
        saturationBrightnessPickerView.hue = hue
        alphaPickerView.hue = hue
        colorView.backgroundColor = saturationBrightnessPickerView.color.colorWithAlphaComponent(alphaPickerView.alphaValue)
    }
}

extension ColorPickerView: AlphaPickerViewDelegate {
    public func alphaPicked(alphaPickerView: AlphaPickerView, alpha: CGFloat) {
        let color = saturationBrightnessPickerView.color
        colorView.backgroundColor = color.colorWithAlphaComponent(alpha)
    }
}
