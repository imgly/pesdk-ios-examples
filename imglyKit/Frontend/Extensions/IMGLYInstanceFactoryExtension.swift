//
//  IMGLYInstanceFactoryExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 30/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import CoreGraphics

extension IMGLYInstanceFactory {
    // MARK: - Editor View Controllers
    
    /**
    Return the viewcontroller according to the button-type.
    This is used by the main menu.
    
    - parameter type: The type of the button pressed.
    
    - returns: A viewcontroller according to the button-type.
    */
    public class func viewControllerForEditorActionType(actionType: IMGLYMainEditorActionType, withFixedFilterStack fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYSubEditorViewController? {
        switch (actionType) {
        case .Filter:
            return filterEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Stickers:
            return stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Orientation:
            return orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Focus:
            return focusEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Crop:
            return cropEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Brightness:
            return brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Contrast:
            return contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Saturation:
            return saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case .Text:
            return textEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        default:
            return nil
        }
    }
    
    public class func filterEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYFilterEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYFilterEditorViewController.self).init() as! IMGLYFilterEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYStickersEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYStickersEditorViewController.self).init() as! IMGLYStickersEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYOrientationEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYOrientationEditorViewController.self).init() as! IMGLYOrientationEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYFocusEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYFocusEditorViewController.self).init() as! IMGLYFocusEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYCropEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYCropEditorViewController.self).init() as! IMGLYCropEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYBrightnessEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYBrightnessEditorViewController.self).init() as! IMGLYBrightnessEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYContrastEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYContrastEditorViewController.self).init() as! IMGLYContrastEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYSaturationEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYSaturationEditorViewController.self).init() as! IMGLYSaturationEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    public class func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYTextEditorViewController {
        let vc = configuration.getClassForReplacedClass(IMGLYTextEditorViewController.self).init() as! IMGLYTextEditorViewController
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }
    
    // MARK: - Gradient Views
    
    public class func circleGradientView() -> IMGLYCircleGradientView {
        return IMGLYCircleGradientView(frame: CGRectZero)
    }
    
    public class func boxGradientView() -> IMGLYBoxGradientView {
        return IMGLYBoxGradientView(frame: CGRectZero)
    }
    
    // MARK: - Helpers
    
    public class func cropRectComponent() -> IMGLYCropRectComponent {
        return IMGLYCropRectComponent()
    }
}
