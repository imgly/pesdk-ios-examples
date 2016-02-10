//
//  BrightnessEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYBrightnessEditorViewController) public class BrightnessEditorViewController: SliderEditorViewController {

    // MARK: - UIViewController

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

    override public var options: SliderEditorViewControllerOptions {
        return self.configuration.brightnessEditorViewControllerOptions
    }

    override public var minimumValue: Float {
        return -1
    }

    override public var maximumValue: Float {
        return 1
    }

    override public var initialValue: Float {
        return fixedFilterStack.brightnessFilter.brightness
    }

    override public func valueChanged(value: Float) {
        fixedFilterStack.brightnessFilter.brightness = slider.value
    }

}
