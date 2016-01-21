//
//  CropEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// Used to configure the crop action buttons. A button and its action are given as parameters.
public typealias CropActionButtonConfigurationClosure = (ImageCaptionButton, CropAction) -> ()

@objc(IMGLYCropEditorViewControllerOptions) public class CropEditorViewControllerOptions: EditorViewControllerOptions {
    /// Defines all allowed focus actions. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off action is always added. To set this
    /// property from Obj-C, see the `allowedCropActionsAsNSNumbers` property.
    public let allowedCropActions: [CropAction]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: CropActionButtonConfigurationClosure?

    public convenience init() {
        self.init(builder: CropEditorViewControllerOptionsBuilder())
    }

    public init(builder: CropEditorViewControllerOptionsBuilder) {
        allowedCropActions = builder.allowedCropActions
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYCropEditorViewControllerOptionsBuilder) public class CropEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Defines all allowed focus actions. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off action is always added. To set this
    /// property from Obj-C, see the `allowedCropActionsAsNSNumbers` property.
    public var allowedCropActions: [CropAction] = [ .Free, .OneToOne, .FourToThree, .SixteenToNine ]

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: CropActionButtonConfigurationClosure? = nil

    // MARK: Obj-C Compatibility

    /// An array of `OrientationAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedOrientationActions` with the corresponding `FocusAction` values.
    public var allowedCropActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedCropActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedCropActions = newValue.flatMap { CropAction(rawValue: $0.integerValue) }
        }
    }


    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Crop")
    }
}
