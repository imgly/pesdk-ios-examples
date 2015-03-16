//
//  IMGLYColorButton.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

public class IMGLYColorButton : UIButton {
    private var hasFrame_ = false
    public var hasFrame:Bool {
        get {
            return hasFrame_
        }
        set (frame) {
            hasFrame_ = frame
            styleButton()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        styleButton()
    }
    
    private func styleButton() {
        selected = false
        setNeedsDisplay()
        layer.cornerRadius = 3
        layer.masksToBounds = true
        layer.borderWidth = 2.0
        var alpha = hasFrame ? 0.5 : 0.0
        layer.borderColor = UIColor(white: 1.0, alpha: CGFloat(alpha)).CGColor
    }
}
