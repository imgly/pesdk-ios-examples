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

    public var selectionColor = UIColor.redColor() {
        didSet {
            styleButton()
        }
    }

    public var textColor = UIColor.whiteColor() {
        didSet {
            styleButton()
        }
    }

    public var fontName = "" {
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

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

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
        titleLabel?.textColor = textColor
        setTitle(dummyText, forState: .Normal)
        titleLabel!.sizeToFit()
        if fontName.characters.count > 0 {
            titleLabel?.font = UIFont(name: fontName, size: fontSize)
            fontNameLabel.text = fontName
        }
        fontNameLabel.textColor = textColor
        fontNameLabel.frame = CGRect(x: 0, y: self.bounds.height - 10, width: self.bounds.width, height: 10)
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
