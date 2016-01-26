//
//  StickersEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit


@objc(IMGLYStickersEditorViewControllerOptions) public class StickersEditorViewControllerOptions: EditorViewControllerOptions {
    /// An object conforming to the `StickersDataSourceProtocol`
    /// Per default an `StickersDataSource` offering all filters
    /// is set.
    public let stickersDataSource: StickersDataSourceProtocol

    /// Disables/Enables the pinch gesture on stickers to change their size.
    public let canModifyStickerSize: Bool

    /// Enables/Disables the delete sticker button. Defaults to true.
    public var canDeleteSticker: Bool

    /// Enables/Disables the flip-horizontal button. Defaults to true.
    public var canFlipHorizontaly: Bool

    /// Enables/Disables the flip-vertical button. Defaults to true.
    public var canFlipVerticaly: Bool

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha: CGFloat

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha: CGFloat

    public convenience init() {
        self.init(builder: StickersEditorViewControllerOptionsBuilder())
    }

    public init(builder: StickersEditorViewControllerOptionsBuilder) {
        stickersDataSource = builder.stickersDataSource
        canModifyStickerSize = builder.canModifyStickerSize
        canDeleteSticker = builder.canDeleteSticker
        canFlipHorizontaly = builder.canFlipHorizontaly
        canFlipVerticaly = builder.canFlipVerticaly
        disabledOverlayButtonAlpha = builder.disabledOverlayButtonAlpha
        enabledOverlayButtonAlpha = builder.enabledOverlayButtonAlpha
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYStickersEditorViewControllerOptionsBuilder) public class StickersEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// An object conforming to the `StickersDataSourceProtocol`
    /// Per default an `StickersDataSource` offering all filters
    /// is set.
    public var stickersDataSource: StickersDataSourceProtocol = StickersDataSource()

    /// Disables/Enables the pinch gesture on stickers to change their size.
    public var canModifyStickerSize = true

    /// Enables/Disables the delete sticker button. Defaults to true.
    public var canDeleteSticker = true

    /// Enables/Disables the flip-horizontal button. Defaults to true.
    public var canFlipHorizontaly = true

    /// Enables/Disables the flip-vertical button. Defaults to true.
    public var canFlipVerticaly = true

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha = CGFloat(0.2)

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha = CGFloat(0.6)

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Stickers")
    }
}
