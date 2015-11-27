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
    public class func viewControllerForButtonType(type: IMGLYMainMenuButtonType, withFixedFilterStack fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYSubEditorViewController? {
        switch (type) {
        case IMGLYMainMenuButtonType.Filter:
            return filterEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Stickers:
            return stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Orientation:
            return orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Focus:
            return focusEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Crop:
            return cropEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Brightness:
            return brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Contrast:
            return contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Saturation:
            return saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        case IMGLYMainMenuButtonType.Text:
            return textEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        default:
            return nil
        }
    }
    
    public class func filterEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYFilterEditorViewController {
        return IMGLYFilterEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYStickersEditorViewController {
        return IMGLYStickersEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYOrientationEditorViewController {
        return IMGLYOrientationEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYFocusEditorViewController {
        return IMGLYFocusEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYCropEditorViewController {
        return IMGLYCropEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYBrightnessEditorViewController {
        return IMGLYBrightnessEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYContrastEditorViewController {
        return IMGLYContrastEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYSaturationEditorViewController {
        return IMGLYSaturationEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
    }
    
    public class func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYTextEditorViewController {
        return IMGLYTextEditorViewController(fixedFilterStack: fixedFilterStack, configuration: configuration)
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
