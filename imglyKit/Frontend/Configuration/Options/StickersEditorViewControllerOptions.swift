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

    public convenience init() {
        self.init(builder: StickersEditorViewControllerOptionsBuilder())
    }

    public init(builder: StickersEditorViewControllerOptionsBuilder) {
        stickersDataSource = builder.stickersDataSource
        canModifyStickerSize = builder.canModifyStickerSize
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

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Stickers")
    }
}
