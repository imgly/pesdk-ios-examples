//
//  OrientationEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// The definition of the configuration closure.
public typealias OrientationActionButtonConfigurationClosure = (ImageCaptionButton, OrientationAction) -> ()

/// This closure is called every time the user selects an action
public typealias OrientationActionSelectedClosure = (OrientationAction) -> ()

// swiftlint:disable type_name
/**
Options for configuring a `OrientationEditorViewController`.
*/
@objc(IMGLYOrientationEditorViewControllerOptions) public class OrientationEditorViewControllerOptions: EditorViewControllerOptions {
    // swiftlint:enable type_name

    /// Defines all allowed actions. The action buttons are shown in the given order.
    /// Defaults to show all available actions.
    public let allowedOrientationActions: [OrientationAction]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: OrientationActionButtonConfigurationClosure?

    /// This closure is called every time the user selects an action
    public let orientationActionSelectedClosure: OrientationActionSelectedClosure?

    /**
     Returns a newly allocated instance of a `OrientationEditorViewControllerOptions` using the default builder.

     - returns: An instance of a `OrientationEditorViewControllerOptions`.
     */
    public convenience init() {
        self.init(builder: OrientationEditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `OrientationEditorViewControllerOptions` using the given builder.

     - parameter builder: A `OrientationEditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `OrientationEditorViewControllerOptions`.
     */
    public init(builder: OrientationEditorViewControllerOptionsBuilder) {
        allowedOrientationActions = builder.allowedOrientationActions
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        orientationActionSelectedClosure = builder.orientationActionSelectedClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
/**
The default `OrientationEditorViewControllerOptionsBuilder` for `OrientationEditorViewControllerOptions`.
*/
@objc(IMGLYOrientationEditorViewControllerOptionsBuilder) public class OrientationEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Defines all allowed actions. The action buttons are always shown in the given order.
    /// Defaults to show all available actions. To set this
    /// property from Obj-C, see the `allowedOrientationActionsAsNSNumbers` property.
    public var allowedOrientationActions: [OrientationAction] = [ .RotateLeft, .RotateRight, .FlipHorizontally, .FlipVertically ]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: OrientationActionButtonConfigurationClosure? = nil


    /// An array of `OrientationAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedOrientationActions` with the corresponding `FocusAction` values.
    public var allowedOrientationActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedOrientationActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedOrientationActions = newValue.flatMap { OrientationAction(rawValue: $0.integerValue) }
        }
    }

    /// This closure is called every time the user selects an action
    public var orientationActionSelectedClosure: OrientationActionSelectedClosure? = nil

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Orientation")
    }
}
