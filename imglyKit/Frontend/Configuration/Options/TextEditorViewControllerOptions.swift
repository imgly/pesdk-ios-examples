//
//  TextEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYTextEditorViewControllerOptions) public class TextEditorViewControllerOptions: EditorViewControllerOptions {
    /// Use this closure to configure the text input field.
    /// Defaults to an empty implementation.
    public let textFieldConfigurationClosure: TextFieldConfigurationClosure?

    /// Defaults to white.
    public let fontPreviewTextColor: UIColor

    /// An optional array of custom color values. The user can select a text color
    /// from the given values. If no colors are passed, a default color set is loaded.
    public let availableFontColors: [UIColor]?

    /// Enables/Disables the add text button. Defaults to true.
    public let canAddText: Bool

    /// Enables/Disables the delete text button. Defaults to true.
    public let canDeleteText: Bool

    /// Enables/Disables the pinch gesture, that allows resizing of the current text. Defaults to true.
    public let canModifyTextSize: Bool

    /// Enables/Disables text color changes through the bottom drawer. Defaults to true.
    public let canModifyTextColor: Bool

    /// Enables/Disables background color changes through the bottom drawer. Defaults to true.
    public let canModifyBackgroundColor: Bool

    /// Enables/Disables the bring to front option. Defaults to true.
    public let canBringToFront: Bool

    /// Enables/Disables font changes through the bottom drawer. Defaults to true.
    public let canModifyTextFont: Bool

    /// The name of the default Font. Defaults to 'Helvetica Neue'.
    public let defaultFontName: String

    /// The background color of the add text button. Defaults to petrol.
    public let addButtonBackgroundColor: UIColor

    /// The background color of the delete text button. Defaults to petrol.
    public let deleteButtonBackgroundColor: UIColor

    /// The background color of the handle, that is used to pull up detail views. Defaults to petrol.
    public let handleBackgroundColor: UIColor

    /// The color of the handle, that is used to pull up detail views. Defaults to white.
    public let handleColor: UIColor

    public convenience init() {
        self.init(builder: TextEditorViewControllerOptionsBuilder())
    }

    public init(builder: TextEditorViewControllerOptionsBuilder) {
        textFieldConfigurationClosure = builder.textFieldConfigurationClosure
        fontPreviewTextColor = builder.fontPreviewTextColor
        availableFontColors = builder.availableFontColors
        canAddText = builder.canAddText
        canDeleteText = builder.canDeleteText
        canModifyTextSize = builder.canModifyTextSize
        canModifyTextColor = builder.canModifyTextColor
        canModifyBackgroundColor = builder.canModifyBackgroundColor
        canBringToFront = builder.canBringToFront
        canModifyTextFont = builder.canModifyTextFont
        defaultFontName = builder.defaultFontName
        addButtonBackgroundColor = builder.addButtonBackgroundColor
        deleteButtonBackgroundColor = builder.deleteButtonBackgroundColor
        handleBackgroundColor = builder.handleBackgroundColor
        handleColor = builder.handleColor
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYTextEditorViewControllerOptionsBuilder) public class TextEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Use this closure to configure the text input field.
    public var textFieldConfigurationClosure: TextFieldConfigurationClosure? = nil

    /// Defaults to white.
    public var fontPreviewTextColor: UIColor = UIColor.whiteColor()

    /// An optional array of custom color values. The user can select a text color
    /// from the given values. If no colors are passed, a default color set is loaded.
    public var availableFontColors: [UIColor]?

    /// Enables/Disables the add text button. Defaults to true.
    public var canAddText = true

    /// Enables/Disables the delete text button. Defaults to true.
    public var canDeleteText = true

    /// Enables/Disables the pinch gesture, that allows resizing of the current text. Defaults to true.
    public var canModifyTextSize = true

    /// Enables/Disables color changes through the bottom drawer. Defaults to true.
    public var canModifyTextColor = true

    /// Enables/Disables background color changes through the bottom drawer. Defaults to true.
    public var canModifyBackgroundColor = true

    /// Enables/Disables the bring to front option. Defaults to true.
    public var canBringToFront = true

    /// Enables/Disables font changes through the bottom drawer. Defaults to true.
    public var canModifyTextFont = true

    /// The name of the default Font. Defaults to 'Helvetica Neue'.
    public var defaultFontName = "Helvetica Neue"

    /// The background color of the add text button. Defaults to petrol.
    public var addButtonBackgroundColor = UIColor(red: 0, green: 0.48, blue: 0.56, alpha: 1.0)

    /// The background color of the delete text button. Defaults to petrol.
    public var deleteButtonBackgroundColor = UIColor(red: 0, green: 0.48, blue: 0.56, alpha: 1.0)

    /// The background color of the handle, that is used to pull up detail views. Defaults to petrol.
    public let handleBackgroundColor = UIColor(red: 0, green: 0.48, blue: 0.56, alpha: 1.0)

    /// The color of the handle, that is used to pull up detail views. Defaults to light gray.
    public let handleColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)


    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Text")
    }
}
