//
//  SaturationEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYSaturationEditorViewController) public class SaturationEditorViewController: SliderEditorViewController {

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        slider.accessibilityLabel = Localize("Saturation")

        let defaultTitle = Localize("Saturation")
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
        return self.configuration.saturationEditorViewControllerOptions
    }

    override public var minimumValue: Float {
        return 0
    }

    override public var maximumValue: Float {
        return 2
    }

    override public var initialValue: Float {
        return fixedFilterStack.brightnessFilter.saturation
    }

    override public func valueChanged(value: Float) {
        fixedFilterStack.brightnessFilter.saturation = slider.value
    }

}
