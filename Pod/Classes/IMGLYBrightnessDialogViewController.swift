//
//  IMGLYBrightnessDialogViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYBrightnessDialogViewController: IMGLYCBSBaseViewController, IMGLYCBSBaseViewControllerDelegate {
    
    // MARK:- Framework code
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setup()
    }
    
    // MARK:- IMGLYCBSBaseViewControllerDelegate
    public var caption:String {
        get {
            return "Brightness"
        }
    }
    
    public var minValue:Float {
        get {
            return -1.0
        }
    }
    
    public var maxValue:Float {
        get {
            return 1.0
        }
    }
    
    public var initialValue:Float {
        get {
            if fixedFilterStack != nil {
                return fixedFilterStack!.brightnessFitler!.brightness
            }
            return 0.0
        }
    }
    
    public func setValue(value:Float) {
        if fixedFilterStack != nil {
            fixedFilterStack!.brightnessFitler!.brightness = value
        }
    }
}