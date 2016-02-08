//
//  StickersEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// The definition of the configuration closure.
public typealias StickerActionButtonConfigurationClosure = (UIButton, StickerAction) -> ()

@objc(IMGLYStickersEditorViewControllerOptions) public class StickersEditorViewControllerOptions: EditorViewControllerOptions {
    /// An object conforming to the `StickersDataSourceProtocol`
    /// Per default an `StickersDataSource` offering all filters
    /// is set.
    public let stickersDataSource: StickersDataSourceProtocol

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public let allowedStickerActions: [StickerAction]

    /// Disables/Enables the pinch gesture on stickers to change their size.
    public let canModifyStickerSize: Bool

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha: CGFloat

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha: CGFloat

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: StickerActionButtonConfigurationClosure?

    public convenience init() {
        self.init(builder: StickersEditorViewControllerOptionsBuilder())
    }

    public init(builder: StickersEditorViewControllerOptionsBuilder) {
        stickersDataSource = builder.stickersDataSource
        canModifyStickerSize = builder.canModifyStickerSize
        disabledOverlayButtonAlpha = builder.disabledOverlayButtonAlpha
        enabledOverlayButtonAlpha = builder.enabledOverlayButtonAlpha
        allowedStickerActions = builder.allowedStickerActions
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYStickersEditorViewControllerOptionsBuilder) public class StickersEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: StickerActionButtonConfigurationClosure? = nil

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions. To set this
    /// property from Obj-C, see the `allowedOrientationActionsAsNSNumbers` property.
    public var allowedStickerActions: [StickerAction] = [ .Delete, .BringToFront, .FlipHorizontally, .FlipVertically]

    /// An object conforming to the `StickersDataSourceProtocol`
    /// Per default an `StickersDataSource` offering all filters
    /// is set.
    public var stickersDataSource: StickersDataSourceProtocol = StickersDataSource()

    /// Disables/Enables the pinch gesture on stickers to change their size.
    public var canModifyStickerSize = true

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha = CGFloat(0.0)

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha = CGFloat(1.0)

    /// An array of `StickerAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedStickerActions` with the corresponding `FocusAction` values.
    public var allowedStoclerActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedStickerActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedStickerActions = newValue.flatMap { StickerAction(rawValue: $0.integerValue) }
        }
    }

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Stickers")
    }
}
