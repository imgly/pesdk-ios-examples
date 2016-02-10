//
//  ContrastEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYContrastEditorViewController) public class ContrastEditorViewController: SliderEditorViewController {

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        slider.accessibilityLabel = Localize("Contrast")

        let defaultTitle = Localize("Contrast")
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
        return self.configuration.contrastEditorViewControllerOptions
    }

    override public var minimumValue: Float {
        return 0
    }

    override public var maximumValue: Float {
        return 2
    }

    override public var initialValue: Float {
        return fixedFilterStack.brightnessFilter.contrast
    }

    override public func valueChanged(value: Float) {
        fixedFilterStack.brightnessFilter.contrast = slider.value
    }

}
