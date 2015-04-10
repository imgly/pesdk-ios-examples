//
//  ContrastEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYContrastEditorViewController) public class ContrastEditorViewController: SliderEditorViewController {

    // MARK: - SliderEditorViewController
    
    override public var minimumValue: Float {
        return 0
    }
    
    override public var maximumValue: Float {
        return 2
    }
    
    override public var initialValue: Float {
        return fixedFilterStack.brightnessFilter.contrast
    }
    
    override public func valueChanged(value: Float) {
        fixedFilterStack.brightnessFilter.contrast = slider.value
    }

}
