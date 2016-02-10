//
//  MainEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 Options for configuring a `MainEditorViewController`.
 */
@objc(IMGLYMainEditorViewControllerOptions) public class MainEditorViewControllerOptions: EditorViewControllerOptions {

    /// Specifies the actions available in the bottom drawer. Defaults to the
    /// MainEditorActionsDataSource providing all editors.
    public let editorActionsDataSource: MainEditorActionsDataSourceProtocol

    /// Setting this to `true` results in the crop editor being displayed immediately if the image passed
    /// to the view controller doesn't have an aspect ratio that is equal to one of the allowed crop actions.
    /// This property only works if you do **not** specify `.Free` as one of the allowed crop actions.
    public let forceCrop: Bool

    /**
     Returns a newly allocated instance of a `MainEditorViewControllerOptions` using the default builder.

     - returns: An instance of a `MainEditorViewControllerOptions`.
     */
    public convenience init() {
        self.init(builder: MainEditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `MainEditorViewControllerOptions` using the given builder.

     - parameter builder: A `MainEditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `MainEditorViewControllerOptions`.
     */
    public init(builder: MainEditorViewControllerOptionsBuilder) {
        editorActionsDataSource = builder.editorActionsDataSource
        forceCrop = builder.forceCrop
        super.init(editorBuilder: builder)
    }
}
// swiftlint:disable type_name
/**
    The default `MainEditorViewControllerOptionsBuilder` for `MainEditorViewControllerOptions`.
*/
@objc(IMGLYMainEditorViewControllerOptionsBuilder) public class MainEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Specifies the actions available in the bottom drawer. Defaults to the
    /// MainEditorActionsDataSource providing all editors.
    public var editorActionsDataSource: MainEditorActionsDataSourceProtocol = MainEditorActionsDataSource()

    /// Setting this to `true` results in the crop editor being displayed immediately if the image passed
    /// to the view controller doesn't have an aspect ratio that is equal to one of the allowed crop actions.
    /// This property only works if you do **not** specify `.Free` as one of the allowed crop actions.
    public var forceCrop = false

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values.
        self.title = Localize("Editor")
    }
}
