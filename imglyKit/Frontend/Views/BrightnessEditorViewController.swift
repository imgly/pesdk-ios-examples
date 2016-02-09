//
//  BrightnessEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

/**
 The `BrightnessEditorViewController` class provides a dialog that is used to change the brightness of an image.
 Therefore it changes the brightness value, that is hand over to an instance of a `ContrastBrightnessSaturationFilter`.
 It derives from the `SliderEditorViewController` class that provides a basic slider based dialog.
 */
@objc(IMGLYBrightnessEditorViewController) public class BrightnessEditorViewController: SliderEditorViewController {

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    override public func viewDidLoad() {
        super.viewDidLoad()

        slider.accessibilityLabel = Localize("Brightness")

        let defaultTitle = Localize("Brightness")
        if let title = options.title {
            if title != defaultTitle {
                navigationItem.title = title
            }
        } else {
            navigationItem.title = defaultTitle
        }
    }

    // MARK: - SliderEditorViewController

    /// The options that can be used to customize the dialog.
    override public var options: SliderEditorViewControllerOptions {
        return self.configuration.brightnessEditorViewControllerOptions
    }

    /// The minimum value of the slider.
    override public var minimumValue: Float {
        return -1
    }

    /// The maximum value of the slider.
    override public var maximumValue: Float {
        return 1
    }

    /// The intial value of the slider.
    override public var initialValue: Float {
        return fixedFilterStack.brightnessFilter.brightness
    }

    /**
     This function is called when the slider value changes.
     The new value will be set as brightness parameter for an instance of a `ContrastBrightnessSaturationFilter`.

     - parameter value: The new slider value.
     */
    override public func valueChanged(value: Float) {
        fixedFilterStack.brightnessFilter.brightness = slider.value
    }
}
