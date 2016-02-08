//
//  TextEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// The definition of the configuration closure. Please note the we use
/// 'Any' as type since the button can be a UIButton, ImageCaptionButton, or TextCaptionButton
public typealias TextActionButtonConfigurationClosure = (Any, TextAction) -> ()

/// The definition of the configuration closure, to configure the bottom bar font selector
public typealias FontQuickSelectorButtonConfigurationClosure = (FontButton) -> ()

/// The definition of the configuration closure, to configure the pullable font selector
public typealias FontSelectorButtonConfigurationClosure = (TextButton) -> ()

@objc(IMGLYTextEditorViewControllerOptions) public class TextEditorViewControllerOptions: EditorViewControllerOptions {
    /// Use this closure to configure the text input field.
    /// Defaults to an empty implementation.
    public let textFieldConfigurationClosure: TextFieldConfigurationClosure?

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

    /// The background color of the handle, that is used to pull up detail views. Defaults to petrol.
    public let handleBackgroundColor: UIColor

    /// The color of the handle, that is used to pull up detail views. Defaults to white.
    public let handleColor: UIColor

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public let disabledOverlayButtonAlpha: CGFloat

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public let enabledOverlayButtonAlpha: CGFloat

    /// The color of the font examples on the text selectors
    public let fontSelectorFontColor: UIColor

    /// The color that is used to highlight, that a font is selected
    public let fontSelectorHighlightColor: UIColor

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public let actionButtonConfigurationClosure: TextActionButtonConfigurationClosure?

    /// This closure allows further configuration of the bottom bar font buttons. The closure is called for
    /// each button and has the button and its corresponding action as parameters.
    // swiftlint:disable variable_name
    public let fontQuickSelectorButtonConfigurationClosure: FontQuickSelectorButtonConfigurationClosure?
    // swiftlint:enable variable_name

    /// This closure allows further configuration of the font buttons. The closure is called for
    /// each button and has the button and its corresponding action as parameters.
    public let fontSelectorButtonConfigurationClosure: FontSelectorButtonConfigurationClosure?

    public convenience init() {
        self.init(builder: TextEditorViewControllerOptionsBuilder())
    }

    public init(builder: TextEditorViewControllerOptionsBuilder) {
        textFieldConfigurationClosure = builder.textFieldConfigurationClosure
        availableFontColors = builder.availableFontColors
        canAddText = builder.canAddText
        canDeleteText = builder.canDeleteText
        canModifyTextSize = builder.canModifyTextSize
        canModifyTextColor = builder.canModifyTextColor
        canModifyBackgroundColor = builder.canModifyBackgroundColor
        canBringToFront = builder.canBringToFront
        canModifyTextFont = builder.canModifyTextFont
        defaultFontName = builder.defaultFontName
        handleBackgroundColor = builder.handleBackgroundColor
        handleColor = builder.handleColor
        disabledOverlayButtonAlpha = builder.disabledOverlayButtonAlpha
        enabledOverlayButtonAlpha = builder.enabledOverlayButtonAlpha
        fontSelectorFontColor = builder.fontSelectorFontColor
        fontSelectorHighlightColor = builder.fontSelectorHighlightColor
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        fontQuickSelectorButtonConfigurationClosure = builder.fontQuickSelectorButtonConfigurationClosure
        fontSelectorButtonConfigurationClosure = builder.fontSelectorButtonConfigurationClosure
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYTextEditorViewControllerOptionsBuilder) public class TextEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Use this closure to configure the text input field.
    public var textFieldConfigurationClosure: TextFieldConfigurationClosure? = nil

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

    /// The background color of the handle, that is used to pull up detail views. Defaults to petrol.
    public let handleBackgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)

    /// The color of the handle, that is used to pull up detail views. Defaults to light gray.
    public let handleColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public var disabledOverlayButtonAlpha = CGFloat(0.0)

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public var enabledOverlayButtonAlpha = CGFloat(1.0)

    /// The color of the font examples on the text selectors
    public var fontSelectorFontColor = UIColor(red:1, green:1, blue:1, alpha:1)

    /// The color that is used to highlight, that a font is selected
    public var fontSelectorHighlightColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)

    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: TextActionButtonConfigurationClosure? = nil

    /// This closure allows further configuration of the bottom bar font buttons. The closure is called for
    /// each button and has the button and its corresponding action as parameters.
    // swiftlint:disable variable_name
    public var fontQuickSelectorButtonConfigurationClosure: FontQuickSelectorButtonConfigurationClosure? = nil
    // swiftlint:enable variable_name

    /// This closure allows further configuration of the font buttons. The closure is called for
    /// each button and has the button and its corresponding action as parameters.
    public var fontSelectorButtonConfigurationClosure: FontSelectorButtonConfigurationClosure? = nil

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Text")
    }
}
