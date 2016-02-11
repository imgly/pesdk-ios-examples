//
//  FocusEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// This closure allows the configuration of the given `ImageCaptionButton`,
/// depending on the linked focus action.
public typealias FocusActionButtonConfigurationClosure = (ImageCaptionButton, FocusAction) -> ()

/// This closure is called when the user selects a focus action.
public typealias FocusActionSelectedClosure = (FocusAction) -> ()

/// This closure is called when the user selects a focus action.
public typealias FocusPositionChanged = () -> ()

/**
 Options for configuring a `FocusEditorViewController`.
 */
@objc(IMGLYFocusEditorViewControllerOptions) public class FocusEditorViewControllerOptions: EditorViewControllerOptions {
    /// Defines all allowed focus actions. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off action is always added. To set this
    /// property from Obj-C, see the `allowedFocusActionsAsNSNumbers` property.
    public let allowedFocusActions: [FocusAction]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: FocusActionButtonConfigurationClosure?

    /// This closure is called when the user selects a focus action.
    public let focusActionSelectedClosure: FocusActionSelectedClosure?

    /**
     Returns a newly allocated instance of a `FocusEditorViewControllerOptions` using the default builder.

     - returns: An instance of a `FocusEditorViewControllerOptions`.
     */
    public convenience init() {
        self.init(builder: FocusEditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `FocusEditorViewControllerOptions` using the given builder.

     - parameter builder: A `FocusEditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `FocusEditorViewControllerOptions`.
     */
    public init(builder: FocusEditorViewControllerOptionsBuilder) {
        allowedFocusActions = builder.allowedFocusActions
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        focusActionSelectedClosure = builder.focusActionSelectedClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
/**
The default `FocusEditorViewControllerOptionsBuilder` for `FocusEditorViewControllerOptions`.
*/
@objc(IMGLYFocusEditorViewControllerOptionsBuilder) public class FocusEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Defines all allowed focus actions. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off action is always added. To set this
    /// property from Obj-C, see the `allowedFocusActionsAsNSNumbers` property.
    public var allowedFocusActions: [FocusAction] = [ .Off, .Linear, .Radial ] {
        didSet {
            if !allowedFocusActions.contains(.Off) {
                allowedFocusActions.append(.Off)
            }
        }
    }

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: FocusActionButtonConfigurationClosure? = nil

    /// This closure is called when the user selects a focus action.
    public var focusActionSelectedClosure: FocusActionSelectedClosure? = nil

    /// An array of `FocusAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedFocusActions` with the corresponding `FocusAction` values.
    public var allowedFocusActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedFocusActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedFocusActions = newValue.flatMap { FocusAction(rawValue: $0.integerValue) }
        }
    }

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Focus")
    }
}
