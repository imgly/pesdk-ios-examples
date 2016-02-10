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

    /// The receiver’s delegate.
    /// seealso: `FontSelectorViewDelegate`.
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

    public var labelColor = UIColor.whiteColor() {
        didSet {
            updateTextColor()
        }
    }

    public var selectedFontName = "" {
        didSet {
            updateTextColor()
            scrollToButton()
        }
    }

    public var text = "" {
        didSet {
            updateFontButtonText()
        }
    }

    /// This closure allows further configuration of the bottom bar font buttons. The closure is called for
    /// each button and has the button and its corresponding action as parameters.
    // swiftlint:disable variable_name
    public var fontSelectorButtonConfigurationClosure: FontSelectorButtonConfigurationClosure? = nil
    // swiftlint:enable variable_name


    private let kDistanceBetweenButtons = CGFloat(60)
    private let kFontSize = CGFloat(28)
    private var fontNames = [String]()

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
                if let displayName = InstanceFactory.fontDisplayNames[button.fontName] {
                    button.displayName = displayName
                }
                button.setTitleColor(textColor, forState: .Normal)
                addSubview(button)
                button.addTarget(self, action: "buttonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }

    private func updateFontButtonText() {
        for subview in subviews where subview is TextButton {
            // swiftlint:disable force_cast
            let button = subview as! TextButton
            // swiftlint:enable force_cast
            button.setTitleColor(textColor, forState: .Normal)
            button.labelColor = labelColor
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
                fontSelectorButtonConfigurationClosure?(button)
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

    private func scrollToButton() {
        var selectedButton: UIButton?
        for view in subviews where view is TextButton {
            if let button = view as? TextButton {
                if button.fontName == selectedFontName {
                    selectedButton = button
                }
            }
        }
        if  let button = selectedButton {
            let centerOffset = frame.height / 2.0
            var target = button.center
            target.x = 0
            target.y -= centerOffset
            target.y = max(target.y, 0.0)
            target.y = min(target.y, contentSize.height - frame.height)
            self.setContentOffset(target, animated: true)
        }
    }
}
