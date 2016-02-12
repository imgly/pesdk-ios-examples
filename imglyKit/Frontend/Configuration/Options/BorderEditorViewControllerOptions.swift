//
//  BorderEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 12/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// The definition of the configuration closure.
public typealias BorderActionButtonConfigurationClosure = (UIButton, BorderAction) -> ()

/// This closure is called when the user selects an action.
public typealias BorderActionSelectedClosure = (BorderAction) -> ()

/// This closure is called when the user adds a border.
public typealias AddedBorderClosure = (String) -> ()

/**
 Options for configuring a `BordersEditorViewController`.
 */
@objc(IMGLYBorderEditorViewControllerOptions) public class BorderEditorViewControllerOptions: EditorViewControllerOptions {
    /// An object conforming to the `BordersDataSourceProtocol`
    /// Per default an `BordersDataSource` offering all filters
    /// is set.
    public let bordersDataSource: BordersDataSourceProtocol

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public let allowedBorderActions: [BorderAction]

    /// This closure is called when the user selects an action.
    public let borderActionSelectedClosure: BorderActionSelectedClosure?

    /// This closure is called when the user adds a border.
    public let addedBorderClosure: AddedBorderClosure?

    /// Disables/Enables the pinch gesture on borders to change their size.
    public let canModifyBorderSize: Bool

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha: CGFloat

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha: CGFloat

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: BorderActionButtonConfigurationClosure?

    /**
     Returns a newly allocated instance of a `BordersEditorViewControllerOptions` using the default builder.

     - returns: An instance of a `MainEditorViewControllerOptions`.
     */
    public convenience init() {
        self.init(builder: BordersEditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `BordersEditorViewControllerOptions` using the given builder.

     - parameter builder: A `BordersEditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `BordersEditorViewControllerOptions`.
     */
    public init(builder: BordersEditorViewControllerOptionsBuilder) {
        bordersDataSource = builder.bordersDataSource
        canModifyBorderSize = builder.canModifyBorderSize
        disabledOverlayButtonAlpha = builder.disabledOverlayButtonAlpha
        enabledOverlayButtonAlpha = builder.enabledOverlayButtonAlpha
        allowedBorderActions = builder.allowedBorderActions
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        borderActionSelectedClosure = builder.borderActionSelectedClosure
        addedBorderClosure = builder.addedBorderClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
/**
The default `BordersEditorViewControllerOptionsBuilder` for `BordersEditorViewControllerOptions`.
*/
@objc(IMGLYBordersEditorViewControllerOptionsBuilder) public class BordersEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: BorderActionButtonConfigurationClosure? = nil

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions. To set this
    /// property from Obj-C, see the `allowedOrientationActionsAsNSNumbers` property.
    public var allowedBorderActions: [BorderAction] = [ .Delete, .BringToFront, .FlipHorizontally, .FlipVertically]

    /// An object conforming to the `BordersDataSourceProtocol`
    /// Per default an `BordersDataSource` offering all filters
    /// is set.
    public var bordersDataSource: BordersDataSourceProtocol = RemoteBordersDataSource()

    /// This closure is called when the user selects an action.
    public var borderActionSelectedClosure: BorderActionSelectedClosure? = nil

    /// This closure is called when the user adds a border.
    public var addedBorderClosure: AddedBorderClosure? = nil

    /// Disables/Enables the pinch gesture on borders to change their size.
    public var canModifyBorderSize = true

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha = CGFloat(0.0)

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha = CGFloat(1.0)

    /// An array of `BorderAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedBorderActions` with the corresponding `FocusAction` values.
    public var allowedStoclerActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedBorderActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedBorderActions = newValue.flatMap { BorderAction(rawValue: $0.integerValue) }
        }
    }

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Borders")
    }
}
