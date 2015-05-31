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
    
    :param: type The type of the button pressed.
    
    :returns: A viewcontroller according to the button-type.
    */
    public class func viewControllerForButtonType(type: IMGLYMainMenuButtonType, withFixedFilterStack fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYSubEditorViewController? {
        switch (type) {
        case IMGLYMainMenuButtonType.Filter:
            return filterEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Stickers:
            return stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Orientation:
            return orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Focus:
            return focusEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Crop:
            return cropEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Brightness:
            return brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Contrast:
            return contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Saturation:
            return saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        case IMGLYMainMenuButtonType.Text:
            return textEditorViewControllerWithFixedFilterStack(fixedFilterStack)
        default:
            return nil
        }
    }
    
    public class func filterEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYFilterEditorViewController {
        return IMGLYFilterEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYStickersEditorViewController {
        return IMGLYStickersEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYOrientationEditorViewController {
        return IMGLYOrientationEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYFocusEditorViewController {
        return IMGLYFocusEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYCropEditorViewController {
        return IMGLYCropEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYBrightnessEditorViewController {
        return IMGLYBrightnessEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYContrastEditorViewController {
        return IMGLYContrastEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYSaturationEditorViewController {
        return IMGLYSaturationEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public class func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYTextEditorViewController {
        return IMGLYTextEditorViewController(fixedFilterStack: fixedFilterStack)
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
