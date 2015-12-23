//
//  IMGLYTextColorSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYTextColorSelectorViewDelegate: class {
    func textColorSelectorView(selectorView: IMGLYTextColorSelectorView, didSelectColor color: UIColor)
}

public class IMGLYTextColorSelectorView: UIScrollView {
    public weak var menuDelegate: IMGLYTextColorSelectorViewDelegate?

    private var colorArray: [UIColor] = []
    private var buttonArray = [IMGLYColorButton]()

    private let kButtonYPosition = CGFloat(22)
    private let kButtonXPositionOffset = CGFloat(5)
    private let kButtonDistance = CGFloat(10)
    private let kButtonSideLength = CGFloat(50)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /**
     Creates a text color selection view. If no available colors are given,
     a default color set is presented.
    */
    public convenience init(availableColors: [UIColor]?) {
        self.init()
        if let availableColorsGiven = availableColors {
            self.colorArray = availableColorsGiven
        } else {
            self.colorArray = defaultColorArray()
        }

        commonInit()
    }

    private func commonInit() {
        self.autoresizesSubviews = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        configureColorButtons()
    }

    private func defaultColorArray() -> [UIColor] {
        return [
            UIColor.whiteColor(),
            UIColor.blackColor(),
            UIColor(red: CGFloat(0xec / 255.0), green:CGFloat(0x37 / 255.0), blue:CGFloat(0x13 / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xfc / 255.0), green:CGFloat(0xc0 / 255.0), blue:CGFloat(0x0b / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xa9 / 255.0), green:CGFloat(0xe9 / 255.0), blue:CGFloat(0x0e / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0x0b / 255.0), green:CGFloat(0x6a / 255.0), blue:CGFloat(0xf9 / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xff / 255.0), green:CGFloat(0xff / 255.0), blue:CGFloat(0x00 / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xb5 / 255.0), green:CGFloat(0xe5 / 255.0), blue:CGFloat(0xff / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xff / 255.0), green:CGFloat(0xb5 / 255.0), blue:CGFloat(0xe0 / 255.0), alpha:1.0)]
    }

    private func configureColorButtons() {
        for color in colorArray {
            let button = IMGLYColorButton()
            self.addSubview(button)
            button.addTarget(self, action: "colorButtonTouchedUpInside:", forControlEvents: .TouchUpInside)
            buttonArray.append(button)
            button.backgroundColor = color
            button.hasFrame = true
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutColorButtons()
    }

    private func layoutColorButtons() {
        var xPosition = kButtonXPositionOffset
        for var i = 0; i < colorArray.count; i++ {
            let button = buttonArray[i]
            button.frame = CGRect(x: xPosition,
                y: kButtonYPosition,
                width: kButtonSideLength,
                height: kButtonSideLength)
            xPosition += (kButtonDistance + kButtonSideLength)
        }
        buttonArray[0].hasFrame = true
        contentSize = CGSize(width: xPosition - kButtonDistance + kButtonXPositionOffset, height: 0)
    }

    @objc private func colorButtonTouchedUpInside(button: UIButton) {
        menuDelegate?.textColorSelectorView(self, didSelectColor: button.backgroundColor!)
    }
}
