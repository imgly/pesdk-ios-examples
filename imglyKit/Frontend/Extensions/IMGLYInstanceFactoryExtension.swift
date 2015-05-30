//
//  IMGLYInstanceFactoryExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 30/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

extension IMGLYInstanceFactory {
    // MARK: - Editor View Controllers
    
    /**
    Return the viewcontroller according to the button-type.
    This is used by the main menu.
    
    :param: type The type of the button pressed.
    
    :returns: A viewcontroller according to the button-type.
    */
    public func viewControllerForButtonType(type: IMGLYMainMenuButtonType, withFixedFilterStack fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYSubEditorViewController? {
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
    
    public func filterEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYFilterEditorViewController {
        return IMGLYFilterEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYStickersEditorViewController {
        return IMGLYStickersEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYOrientationEditorViewController {
        return IMGLYOrientationEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYFocusEditorViewController {
        return IMGLYFocusEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYCropEditorViewController {
        return IMGLYCropEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYBrightnessEditorViewController {
        return IMGLYBrightnessEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYContrastEditorViewController {
        return IMGLYContrastEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYSaturationEditorViewController {
        return IMGLYSaturationEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    public func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack) -> IMGLYTextEditorViewController {
        return IMGLYTextEditorViewController(fixedFilterStack: fixedFilterStack)
    }
    
    // MARK: - Gradient Views
    
    public func circleGradientView() -> IMGLYCircleGradientView {
        return IMGLYCircleGradientView(frame: CGRectZero)
    }
    
    public func boxGradientView() -> IMGLYBoxGradientView {
        return IMGLYBoxGradientView(frame: CGRectZero)
    }
    
    // MARK: - Helpers
    
    public func cropRectComponent() -> IMGLYCropRectComponent {
        return IMGLYCropRectComponent()
    }
}
