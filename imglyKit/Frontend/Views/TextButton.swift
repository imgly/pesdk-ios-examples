//
//  TextButton.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 02/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYTextButton) public class TextButton: UIButton {

    public var labelColor = UIColor.whiteColor() {
        didSet {
            updateFontLabel()
        }
    }

    public var fontName = "" {
        didSet {
            updateFontLabel()
        }
    }

    public override var frame: CGRect {
        didSet {
            super.frame = frame
            updateFontNameLabelFrame()
        }
    }

    public var displayName = "" {
        didSet {
            updateFontLabel()
        }
    }

    private let fontNameLabel = UILabel()

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
        configureFontLabel()
        updateFontLabel()
    }

    private func configureFontLabel() {
        fontNameLabel.textAlignment = .Center
        addSubview(fontNameLabel)
    }

    private func updateFontLabel() {
        fontNameLabel.font = fontNameLabel.font.fontWithSize(10)
        fontNameLabel.textColor = labelColor
        if fontName.characters.count > 0 {
            fontNameLabel.text = displayName.characters.count > 0 ? displayName : fontName
        }
    }

    private func updateFontNameLabelFrame() {
        fontNameLabel.frame = CGRect(x: 0, y: self.bounds.height - 15, width: self.bounds.width, height: 15)
    }
}
