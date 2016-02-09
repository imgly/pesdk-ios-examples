//
//  FontButton.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 01/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

@objc(IMGLYFontButton) public class FontButton: UIButton {
    private let kButtonHeight = CGFloat(60)
    private let fontNameLabel = UILabel()

    public var hasFocus = false {
        didSet {
            styleButton()
        }
    }

    public var selectionColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1) {
        didSet {
            styleButton()
        }
    }

    public var textColor = UIColor.whiteColor() {
        didSet {
            styleButton()
        }
    }

    public var labelColor = UIColor.whiteColor() {
        didSet {
            styleButton()
        }
    }

    public var fontName = "" {
        didSet {
            styleButton()
        }
    }

    public var displayName = "" {
        didSet {
            styleButton()
        }
    }

    public var fontSize = CGFloat(20) {
        didSet {
            styleButton()
        }
    }

    public override var frame: CGRect {
        didSet {
            super.frame = frame
            styleButton()
        }
    }

    private let dummyText = "Ag"

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
        configureFontNameLabel()
        styleButton()
    }

    private func styleButton() {
        selected = false
        layer.cornerRadius = 3
        layer.masksToBounds = true
        backgroundColor = hasFocus ? selectionColor : UIColor.clearColor()
        setTitleColor(textColor, forState: .Normal)
        setTitle(dummyText, forState: .Normal)
        titleLabel!.sizeToFit()
        if fontName.characters.count > 0 {
            titleLabel?.font = UIFont(name: fontName, size: fontSize)
            fontNameLabel.text = displayName.characters.count > 0 ? displayName : fontName
        }
        fontNameLabel.textColor = labelColor
        fontNameLabel.frame = CGRect(x: 0, y: self.bounds.height - 15, width: self.bounds.width, height: 10)
        fontNameLabel.textAlignment = NSTextAlignment.Center
        centerTitleLabel()
    }

    private func centerTitleLabel() {
        let textSize = dummyText.sizeWithAttributes([ NSFontAttributeName: titleLabel!.font])
        contentHorizontalAlignment = .Center
        contentVerticalAlignment = .Top
        let topPadding = titleLabel!.font.ascender - titleLabel!.font.capHeight
        let offset =  -textSize.height / 2.0 + kButtonHeight * 0.5 - topPadding * 0.5
        titleEdgeInsets = UIEdgeInsetsMake(offset, 0.0, 0.0, 0.0)
    }

    private func configureFontNameLabel() {
        self.addSubview(fontNameLabel)
        fontNameLabel.font = UIFont(name: fontNameLabel.font!.fontName, size: 10)
    }
}
