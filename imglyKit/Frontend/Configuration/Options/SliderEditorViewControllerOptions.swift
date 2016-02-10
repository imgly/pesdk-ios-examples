//
//  SliderEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 Options for configuring a `SliderEditorViewController`.
 */
@objc(IMGLYSliderEditorViewControllerOptions) public class SliderEditorViewControllerOptions: EditorViewControllerOptions {
    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public let sliderConfigurationClosure: SliderConfigurationClosure?

    /**
     Returns a newly allocated instance of a `SliderEditorViewControllerOptions` using the default builder.

     - returns: An instance of a `SliderEditorViewControllerOptions`.
     */
    public convenience init() {
        self.init(builder: SliderEditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `SliderEditorViewControllerOptions` using the given builder.

     - parameter builder: A `SliderEditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `SliderEditorViewControllerOptions`.
     */
    public init(builder: SliderEditorViewControllerOptionsBuilder) {
        sliderConfigurationClosure = builder.sliderConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
/**
The default `SliderEditorViewControllerOptionsBuilder` for `SliderEditorViewControllerOptions`.
*/
@objc(IMGLYSliderEditorViewControllerOptionsBuilder) public class SliderEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public var sliderConfigurationClosure: SliderConfigurationClosure? = nil
}
