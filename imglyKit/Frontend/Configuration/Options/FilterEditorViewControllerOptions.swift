//
//  FilterEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFilterEditorViewControllerOptions) public class FilterEditorViewControllerOptions: EditorViewControllerOptions {

    // MARK: UI

    // swiftlint:disable variable_name_max_length
    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public let filterIntensitySliderConfigurationClosure: SliderConfigurationClosure
    // swiftlint:enable variable_name_max_length

    /// An object conforming to the `FiltersDataSourceProtocol`
    /// Per default an `FilterSelectionControllerDataSource` offering all filters
    /// is set.
    public let filterDataSource: FiltersDataSourceProtocol

    /// Enable/Disable the filter intensity slider. Defaults to true.
    public let showFilterIntensitySlider: Bool

    public convenience init() {
        self.init(builder: FilterEditorViewControllerOptionsBuilder())
    }

    public init(builder: FilterEditorViewControllerOptionsBuilder) {
        filterIntensitySliderConfigurationClosure = builder.filterIntensitySliderConfigurationClosure
        filterDataSource = builder.filterDataSource
        showFilterIntensitySlider = builder.showFilterIntensitySlider
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYFilterEditorViewControllerOptionsBuilder) public class FilterEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    // swiftlint:disable variable_name_max_length
    /// Use this closure to configure the filter intensity slider.
    /// Defaults to an empty implementation.
    public var filterIntensitySliderConfigurationClosure: SliderConfigurationClosure = { _ in }
    // swiftlint:enable variable_name_max_length

    /// An object conforming to the `FiltersDataSourceProtocol`
    /// Per default an `FilterSelectionControllerDataSource` offering all filters
    /// is set.
    public var filterDataSource: FiltersDataSourceProtocol = FiltersDataSource()

    /// Enable/Disable the filter intensity slider. Defaults to true.
    public var showFilterIntensitySlider = true

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Filter")
    }
}
