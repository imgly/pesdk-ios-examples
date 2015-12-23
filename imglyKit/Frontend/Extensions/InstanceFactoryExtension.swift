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
        switch actionType {
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
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYFilterEditorViewController.self).init() as! IMGLYFilterEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYStickersEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYStickersEditorViewController.self).init() as! IMGLYStickersEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYOrientationEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYOrientationEditorViewController.self).init() as! IMGLYOrientationEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYFocusEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYFocusEditorViewController.self).init() as! IMGLYFocusEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYCropEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYCropEditorViewController.self).init() as! IMGLYCropEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYBrightnessEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYBrightnessEditorViewController.self).init() as! IMGLYBrightnessEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYContrastEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYContrastEditorViewController.self).init() as! IMGLYContrastEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYSaturationEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYSaturationEditorViewController.self).init() as! IMGLYSaturationEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) -> IMGLYTextEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(IMGLYTextEditorViewController.self).init() as! IMGLYTextEditorViewController
        // swiftlint:enable force_cast
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
