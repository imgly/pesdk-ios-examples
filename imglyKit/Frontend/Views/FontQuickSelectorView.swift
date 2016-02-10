//
//  FontQuickSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 01/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFontQuickSelectorViewDelegate) public protocol FontQuickSelectorViewDelegate {
    func fontSelectorView(selectorView: FontQuickSelectorView, didSelectFont fontName: String)
}


@objc(IMGLYFontQuickSelectorView) public class FontQuickSelectorView: UIScrollView {

    /// The receiver’s delegate.
    /// seealso: `FontQuickSelectorViewDelegate`.
    public weak var selectorDelegate: FontQuickSelectorViewDelegate?

    public var selectedTextColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1) {
        didSet {
            updateButtonColors()
        }
    }

    public var textColor = UIColor.whiteColor() {
        didSet {
            updateButtonColors()
        }
    }

    /// This closure allows further configuration of the font buttons. The closure is called for
    /// each button and has the button and its corresponding action as parameters.
    // swiftlint:disable variable_name
    public var fontQuickSelectorButtonConfigurationClosure: FontQuickSelectorButtonConfigurationClosure? = nil
    // swiftlint:enable variable_name

    private var fontNames = [String]()
    private var buttonArray = [FontButton]()

    private let kButtonYPosition = CGFloat(22)
    private let kButtonXPositionOffset = CGFloat(5)
    private let kButtonDistance = CGFloat(5)
    private let kButtonWidth = CGFloat(60)
    private let kButtonHeight = CGFloat(60)

    public var selectedFontName = "" {
        didSet {
            updateSelectedButton()
            scrollToButton()
        }
    }

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
            if let displayName = InstanceFactory.fontDisplayNames[button.fontName] {
                button.displayName = displayName
            }
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
            fontQuickSelectorButtonConfigurationClosure?(button)
        }
        contentSize = CGSize(width: xPosition - kButtonDistance + kButtonXPositionOffset, height: 0)
    }

    @objc private func buttonTouchedUpInside(button: UIButton) {
        if let fontButton = button as? FontButton {
            selectedFontName = fontButton.fontName
            updateSelectedButton()
            selectorDelegate?.fontSelectorView(self, didSelectFont: selectedFontName)
        }
    }

    private func updateSelectedButton() {
        for button in buttonArray {
            let buttonFontMatches = button.fontName == selectedFontName
            button.hasFocus = buttonFontMatches
        }
    }

    private func updateButtonColors() {
        for button in buttonArray {
            button.textColor = textColor
            button.selectionColor = selectedTextColor
        }
    }

    private func scrollToButton() {
        if  let selectedButtonIndex = buttonArray.indexOf({ $0.hasFocus }) {
            let centerOffset = frame.width / 2.0
            var target = buttonArray[selectedButtonIndex].center
            target.x -= centerOffset
            target.x = max(target.x, 0.0)
            target.x = min(target.x, contentSize.width - frame.width)
            target.y = 0
            self.setContentOffset(target, animated: true)
        }
    }
}
