//
//  TextEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/// The definition of the configuration closure. Please note the we use
/// 'Any' as type since the button can be a UIButton, ImageCaptionButton, or TextCaptionButton.
public typealias TextActionButtonConfigurationClosure = (AnyObject, TextAction) -> ()

/// The definition of the configuration closure, to configure the bottom bar font selector.
public typealias FontQuickSelectorButtonConfigurationClosure = (FontButton) -> ()

/// The definition of the configuration closure, to configure the pullable font selector.
public typealias FontSelectorButtonConfigurationClosure = (TextButton) -> ()

/// The definition of the configuration closure, to configure the pullable font selector.
public typealias PullableViewConfigurationClosure = (PullableView) -> ()

@objc(IMGLYTextEditorViewControllerOptions) public class TextEditorViewControllerOptions: EditorViewControllerOptions {
    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public let allowedTextActions: [TextAction]

    /// Use this closure to configure the text input field.
    /// Defaults to an empty implementation.
    public let textFieldConfigurationClosure: TextFieldConfigurationClosure?

    /// An optional array of custom color values. The user can select a text color
    /// from the given values. If no colors are passed, a default color set is loaded.
    public let availableFontColors: [UIColor]?

    /// Enables/Disables the pinch gesture, that allows resizing of the current text. Defaults to true.
    public let canModifyTextSize: Bool

    /// Enables/Disables the pinch gesture, that allows rotation of the current text. Defaults to true.
    public let canModifyTextRotation: Bool

    /// Enables/Disables the long press gesture, that allows editing the text. Defaults to true.
    public let canModifyText: Bool

    /// Enables/Diables the apearance of the new text dialog, as soon as the user opens the text tool.
    public let openNewTextDialogAutomatically: Bool

    /// The name of the default Font. Defaults to 'Helvetica Neue'.
    public let defaultFontName: String

    /// This value determins the opacity of any disabled button that is positions above the preview.
    public let disabledOverlayButtonAlpha: CGFloat

    /// This value determins the opacity of any enabled button that is positions above the preview.
    public let enabledOverlayButtonAlpha: CGFloat

    /// The color of the font examples on the text selectors.
    public let fontSelectorFontColor: UIColor

    /// The color that is used to highlight, that a font is selected.
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

    /// This closure allows further configuration of the pullable view. Such as the handle color.
    public let pullableViewConfigurationClosure: PullableViewConfigurationClosure?

    public convenience init() {
        self.init(builder: TextEditorViewControllerOptionsBuilder())
    }

    public init(builder: TextEditorViewControllerOptionsBuilder) {
        textFieldConfigurationClosure = builder.textFieldConfigurationClosure
        availableFontColors = builder.availableFontColors
        canModifyTextSize = builder.canModifyTextSize
        defaultFontName = builder.defaultFontName
        disabledOverlayButtonAlpha = builder.disabledOverlayButtonAlpha
        enabledOverlayButtonAlpha = builder.enabledOverlayButtonAlpha
        fontSelectorFontColor = builder.fontSelectorFontColor
        fontSelectorHighlightColor = builder.fontSelectorHighlightColor
        actionButtonConfigurationClosure = builder.actionButtonConfigurationClosure
        fontQuickSelectorButtonConfigurationClosure = builder.fontQuickSelectorButtonConfigurationClosure
        fontSelectorButtonConfigurationClosure = builder.fontSelectorButtonConfigurationClosure
        allowedTextActions = builder.allowedTextActions
        pullableViewConfigurationClosure = builder.pullableViewConfigurationClosure
        openNewTextDialogAutomatically = builder.openNewTextDialogAutomatically
        canModifyTextRotation = builder.canModifyTextRotation
        canModifyText = builder.canModifyText
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYTextEditorViewControllerOptionsBuilder) public class TextEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Defines all allowed actions. Only buttons for allowed action are visible.
    /// Defaults to show all available actions.
    public var allowedTextActions: [TextAction] = [.SelectFont, .SelectColor, .SelectBackgroundColor, .Add, .Delete,
        .AcceptColor, .RejectColor, .AcceptFont, .RejectFont, .BringToFront]
    /// Use this closure to configure the text input field.
    public var textFieldConfigurationClosure: TextFieldConfigurationClosure? = nil

    /// An optional array of custom color values. The user can select a text color
    /// from the given values. If no colors are passed, a default color set is loaded.
    public var availableFontColors: [UIColor]?

    /// Enables/Disables the pinch gesture, that allows resizing of the current text. Defaults to true.
    public var canModifyTextSize = true

    /// Enables/Disables the pinch gesture, that allows rotation of the current text. Defaults to true.
    public var canModifyTextRotation = true

    /// Enables/Disables the long press gesture, that allows editing the text. Defaults to true.
    public var canModifyText = true

    /// Enables/Diables the apearance of the new text dialog, as soon as the user opens the text tool.
    public var openNewTextDialogAutomatically = true

    /// The name of the default Font. Defaults to 'Helvetica Neue'.
    public var defaultFontName = "Helvetica Neue"

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

    /// This closure allows further configuration of the pullable view. Such as the handle color.
    public var pullableViewConfigurationClosure: PullableViewConfigurationClosure? = nil

    /// An array of `TextAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedOrientationActions` with the corresponding `FocusAction` values.
    public var allowedTextActionsAsNSNumbers: [NSNumber] {
        get {
            return allowedTextActions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedTextActions = newValue.flatMap { TextAction(rawValue: $0.integerValue) }
        }
    }

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Text")
    }
}
