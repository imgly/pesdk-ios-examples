//
//  SliderEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYSliderEditorViewControllerOptions) public class SliderEditorViewControllerOptions: EditorViewControllerOptions {
    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public let sliderConfigurationClosure: SliderConfigurationClosure

    public convenience init() {
        self.init(builder: SliderEditorViewControllerOptionsBuilder())
    }

    public init(builder: SliderEditorViewControllerOptionsBuilder) {
        sliderConfigurationClosure = builder.sliderConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYSliderEditorViewControllerOptionsBuilder) public class SliderEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public lazy var sliderConfigurationClosure: SliderConfigurationClosure = { _ in }
}
