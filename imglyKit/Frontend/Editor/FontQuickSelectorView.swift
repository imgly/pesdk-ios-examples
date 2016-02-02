//
//  FontQuickSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 01/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFontQuickSelectorViewDelegate) public protocol FontQuickSelectorViewDelegate {
    func fontSelectorView(selectorView: FontQuickSelectorView, didSelectFont fontNamew: String)
}


@objc(IMGLYFontQuickSelectorView) public class FontQuickSelectorView: UIScrollView {
    public weak var selectorDelegate: FontQuickSelectorViewDelegate?

    private var fontNames = [String]()
    private var buttonArray = [FontButton]()

    private let kButtonYPosition = CGFloat(22)
    private let kButtonXPositionOffset = CGFloat(5)
    private let kButtonDistance = CGFloat(5)
    private let kButtonWidth = CGFloat(60)
    private let kButtonHeight = CGFloat(60)

    public var initialFontName = "" {
        didSet {
            updateSelectedButton(initialFontName)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        fontNames = InstanceFactory.availableFontsList
        self.autoresizesSubviews = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        configureFontButtons()
    }

    private func configureFontButtons() {
        for fontName in fontNames {
            let button = FontButton()
            button.fontName = fontName
            self.addSubview(button)
            button.addTarget(self, action: "buttonTouchedUpInside:", forControlEvents: .TouchUpInside)
            buttonArray.append(button)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }

    private func layoutButtons() {
        var xPosition = kButtonXPositionOffset

        for i in 0 ..< fontNames.count {
            let button = buttonArray[i]
            button.frame = CGRect(x: xPosition,
                y: kButtonYPosition,
                width: kButtonWidth,
                height: kButtonHeight)
            xPosition += (kButtonDistance + kButtonWidth)
        }
        contentSize = CGSize(width: xPosition - kButtonDistance + kButtonXPositionOffset, height: 0)
    }

    @objc private func buttonTouchedUpInside(button: UIButton) {
        if let fontButton = button as? FontButton {
            updateSelectedButton(fontButton.fontName)
            fontButton.hasFocus = true
            selectorDelegate?.fontSelectorView(self, didSelectFont: fontButton.fontName)
        }
    }

    private func updateSelectedButton(selectedFontName: String) {
        for button in buttonArray {
            let buttonFontMatches = button.fontName == selectedFontName
            if button.hasFocus && !buttonFontMatches {
                button.hasFocus = false
            } else {
                if !button.hasFocus && buttonFontMatches {
                    button.hasFocus = true
                }
            }
        }
    }
}
