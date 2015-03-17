//
//  IMGLYFontSelector.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 06/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public protocol IMGLYFontSelectorDelegate: class {
    func selectedFontWithName(fontName:String)
}

public class IMGLYFontSelector: UIScrollView {
    public weak var selectorDelegate:IMGLYFontSelectorDelegate? = nil
    
    private let kDistanceBetweenButtons = CGFloat(60)
    private let kFontSize = CGFloat(28)
    private var fontNames_:[String] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 0.0, alpha: 0.4)
       
        fontNames_ = IMGLYInstanceFactory.sharedInstance.availableFontsList()
        configureFontButtons()
    }
    
    private func configureFontButtons() {
        for fontName in fontNames_ {
            println("\(fontName)")
            var button:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            button.setTitle(fontName, forState:UIControlState.Normal)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            var font = UIFont(name: fontName, size: kFontSize)
            button.titleLabel!.font = font!
            addSubview(button)
            button.addTarget(self, action: "buttonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        for var index = 0; index < subviews.count; index++ {
            //var view = subviews[index]
            if let button = subviews[index] as? UIButton {
                button.frame = CGRectMake(0,
                    CGFloat(index) * kDistanceBetweenButtons,
                    frame.size.width,
                    kDistanceBetweenButtons)
            }
        }
        contentSize = CGSizeMake(frame.size.width - 1.0, kDistanceBetweenButtons * CGFloat(subviews.count - 2))
    }
    
    public func buttonTouchedUpInside(button:UIButton) {
        selectorDelegate?.selectedFontWithName(button.titleLabel!.text!)
    }
 }
