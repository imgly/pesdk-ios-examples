//
//  SliderEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// This closure will be called when the user changes the value of a slider.
public typealias SliderChangedValueClosure = (Float) -> ()

/**
 Options for configuring a `SliderEditorViewController`.
 */
@objc(IMGLYSliderEditorViewControllerOptions) public class SliderEditorViewControllerOptions: EditorViewControllerOptions {

    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public let sliderConfigurationClosure: SliderConfigurationClosure?

    /// This closure will be called when the user changes the value of a slider.
    /// Defaults to an empty implementation.
    public let sliderChangedValueClosure: SliderChangedValueClosure?

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
        sliderChangedValueClosure = builder.sliderChangedValueClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
/**
The default `SliderEditorViewControllerOptionsBuilder` for `SliderEditorViewControllerOptions`.
*/
@objc(IMGLYSliderEditorViewControllerOptionsBuilder) public class SliderEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// This closure will be called when the user changes the value of a slider.
    /// Defaults to an empty implementation.
    public var sliderChangedValueClosure: SliderChangedValueClosure? = nil

    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public var sliderConfigurationClosure: SliderConfigurationClosure? = nil
}
