//
//  InstanceFactoryExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 30/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import CoreGraphics

extension InstanceFactory {
    // MARK: - Editor View Controllers

    /**
    Return the viewcontroller according to the button-type.
    This is used by the main menu.

    - parameter type: The type of the button pressed.

    - returns: A viewcontroller according to the button-type.
    */
    public class func viewControllerForEditorActionType(actionType: MainEditorActionType, withFixedFilterStack fixedFilterStack: FixedFilterStack, configuration: Configuration) -> SubEditorViewController? {
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
        case .Border:
            return borderEditorViewControllerWithFixedFilterStack(fixedFilterStack, configuration: configuration)
        default:
            return nil
        }
    }

    public class func filterEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> FilterEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(FilterEditorViewController.self).init() as! FilterEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func stickersEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> StickersEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(StickersEditorViewController.self).init() as! StickersEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func orientationEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> OrientationEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(OrientationEditorViewController.self).init() as! OrientationEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func focusEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> FocusEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(FocusEditorViewController.self).init() as! FocusEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func cropEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> CropEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(CropEditorViewController.self).init() as! CropEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func brightnessEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> BrightnessEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(BrightnessEditorViewController.self).init() as! BrightnessEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func contrastEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> ContrastEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(ContrastEditorViewController.self).init() as! ContrastEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func saturationEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> SaturationEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(SaturationEditorViewController.self).init() as! SaturationEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func textEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> TextEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(TextEditorViewController.self).init() as! TextEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    public class func borderEditorViewControllerWithFixedFilterStack(fixedFilterStack: FixedFilterStack, configuration: Configuration) -> BorderEditorViewController {
        // swiftlint:disable force_cast
        let vc = configuration.getClassForReplacedClass(BorderEditorViewController.self).init() as! BorderEditorViewController
        // swiftlint:enable force_cast
        vc.configuration = configuration
        vc.fixedFilterStack = fixedFilterStack
        return vc
    }

    // MARK: - Gradient Views

    public class func circleGradientView() -> CircleGradientView {
        return CircleGradientView(frame: CGRect.zero)
    }

    public class func boxGradientView() -> BoxGradientView {
        return BoxGradientView(frame: CGRect.zero)
    }

    // MARK: - Helpers

    public class func cropRectComponent() -> CropRectComponent {
        return CropRectComponent()
    }
}
