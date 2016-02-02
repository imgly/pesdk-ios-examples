//
//  FontSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 06/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFontSelectorViewDelegate) public protocol FontSelectorViewDelegate {
    func fontSelectorView(fontSelectorView: FontSelectorView, didSelectFontWithName fontName: String)
}

@objc(IMGLYFontSelectorView) public class FontSelectorView: UIScrollView {
    public weak var selectorDelegate: FontSelectorViewDelegate?
    public var selectedTextColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1) {
        didSet {
            updateTextColor()
        }
    }

    public var textColor = UIColor.whiteColor() {
        didSet {
            updateTextColor()
        }
    }

    public var selectedFontName = "" {
        didSet {
            updateTextColor()
        }
    }

    public var text = "" {
        didSet {
            updateFontButtonText()
        }
    }

    private let kDistanceBetweenButtons = CGFloat(60)
    private let kFontSize = CGFloat(28)
    private var fontNames = [String]()

    public var fontPreviewTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            for subview in self.subviews where subview is TextButton {
                // swiftlint:disable force_cast
                let button = subview as! TextButton
                // swiftlint:enable force_cast
                button.setTitleColor(fontPreviewTextColor, forState: .Normal)
            }
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
        configureFontButtons()
        updateFontButtonText()
    }

    private func configureFontButtons() {
        for fontName in fontNames {
            let button = TextButton(type: UIButtonType.Custom)
            button.setTitle(fontName, forState:UIControlState.Normal)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center

            if let font = UIFont(name: fontName, size: kFontSize) {
                button.titleLabel?.font = font
                button.fontName = fontName
                button.setTitleColor(textColor, forState: .Normal)
                addSubview(button)
                button.addTarget(self, action: "buttonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }

    private func updateFontButtonText() {
        for button in subviews where button is TextButton {
            // swiftlint:disable force_cast
            (button as! TextButton).setTitle(text, forState:UIControlState.Normal)
            // swiftlint:enable force_cast
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        for index in 0 ..< subviews.count {
            if let button = subviews[index] as? TextButton {
                button.frame = CGRect(x: 0,
                    y: CGFloat(index) * kDistanceBetweenButtons,
                    width: frame.size.width,
                    height: kDistanceBetweenButtons)
            }
        }
        contentSize = CGSize(width: frame.size.width - 1.0, height: kDistanceBetweenButtons * CGFloat(subviews.count - 2) + 100)
    }

    @objc private func buttonTouchedUpInside(button: TextButton) {
        let fontName = button.fontName
        selectedFontName = fontName
        updateTextColor()
        selectorDelegate?.fontSelectorView(self, didSelectFontWithName: fontName)
    }

    private func updateTextColor() {
        for view in subviews where view is TextButton {
            if let button = view as? TextButton {
                let color = button.fontName == selectedFontName ? selectedTextColor : textColor
                button.setTitleColor(color, forState: .Normal)
            }
        }
    }
}
