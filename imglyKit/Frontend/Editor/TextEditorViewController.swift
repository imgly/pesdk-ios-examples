//
//  TextEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 17/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let kFontSizeInTextField = CGFloat(20)
private let kTextFieldHeight = CGFloat(40)
private let kTextLabelInitialMargin = CGFloat(40)
private let kMinimumFontSize = CGFloat(12.0)

@objc(IMGLYTextEditorViewControllerOptions) public class TextEditorViewControllerOptions: EditorViewControllerOptions {
    /// Use this closure to configure the text input field.
    /// Defaults to an empty implementation.
    public let textFieldConfigurationClosure: TextFieldConfigurationClosure

    /// Defaults to white.
    public let fontPreviewTextColor: UIColor

    /// An optional array of custom color values. The user can select a text color
    /// from the given values. If no colors are passed, a default color set is loaded.
    public let availableFontColors: [UIColor]?

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

    public convenience init() {
        self.init(builder: TextEditorViewControllerOptionsBuilder())
    }

    public init(builder: TextEditorViewControllerOptionsBuilder) {
        textFieldConfigurationClosure = builder.textFieldConfigurationClosure
        fontPreviewTextColor = builder.fontPreviewTextColor
        availableFontColors = builder.availableFontColors
        canModifyTextSize = builder.canModifyTextSize
        canModifyTextColor = builder.canModifyTextColor
        canModifyBackgroundColor = builder.canModifyBackgroundColor
        canBringToFront = builder.canBringToFront
        canModifyTextFont = builder.canModifyTextFont
        defaultFontName = builder.defaultFontName
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
@objc(IMGLYTextEditorViewControllerOptionsBuilder) public class TextEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// Use this closure to configure the text input field.
    /// Defaults to an empty implementation.
    public lazy var textFieldConfigurationClosure: TextFieldConfigurationClosure = { _ in }

    /// Defaults to white.
    public var fontPreviewTextColor: UIColor = UIColor.whiteColor()

    /// An optional array of custom color values. The user can select a text color
    /// from the given values. If no colors are passed, a default color set is loaded.
    public var availableFontColors: [UIColor]?

    /// Enables/Disables the pinch gesture, that allows resizing of the current text. Defaults to true.
    public var canModifyTextSize = true

    /// Enables/Disables color changes through the bottom drawer. Defaults to true.
    public var canModifyTextColor = true

    /// Enables/Disables background color changes through the bottom drawer. Defaults to true.
    public let canModifyBackgroundColor = true

    /// Enables/Disables the bring to front option. Defaults to true.
    public let canBringToFront = true

    /// Enables/Disables font changes through the bottom drawer. Defaults to true.
    public let canModifyTextFont = true

    /// The name of the default Font. Defaults to 'Helvetica Neue'.
    public let defaultFontName = "Helvetica Neue"

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = NSLocalizedString("text-editor.title", tableName: nil, bundle: NSBundle(forClass: MainEditorViewController.self), value: "", comment: "")
    }
}

@objc(IMGLYTextEditorViewController) public class TextEditorViewController: SubEditorViewController {

    // MARK: - Properties

    private var textColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
    private var fontName = ""
    private var currentTextSize = CGFloat(0)
    private var maximumFontSize = CGFloat(0)
    private var panOffset = CGPointZero
    private var fontSizeAtPinchBegin = CGFloat(0)
    private var distanceAtPinchBegin = CGFloat(0)
    private var draggedView: UILabel?
    private var tempTextCopy = [Filter]()

    public private(set) lazy var addTextButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = ImageCaptionButton()
        button.textLabel.text = NSLocalizedString("text-editor.add", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "addText:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var selectTextFontButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = ImageCaptionButton()
        button.textLabel.text = NSLocalizedString("text-editor.font", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "setTextFont:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var selectTextColorButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = ImageCaptionButton()
        button.textLabel.text = NSLocalizedString("text-editor.text-color", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "setTextColor:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var selectBackgroundColorButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = ImageCaptionButton()
        button.textLabel.text = NSLocalizedString("text-editor.background-color", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "setBackgroundColor:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var bringToFrontButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = ImageCaptionButton()
        button.textLabel.text = NSLocalizedString("text-editor.bring-to-front", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "bringToFront:", forControlEvents: .TouchUpInside)
        return button
    }()


    public private(set) lazy var textClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    public private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = UIColor(white:0.0, alpha:0.5)
        textField.text = ""
        textField.textColor = self.textColor
        textField.clipsToBounds = false
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        textField.returnKeyType = UIReturnKeyType.Done
        self.options.textFieldConfigurationClosure(textField)
        return textField
    }()

    public private(set) lazy var fontSelectorContainerView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .Dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public private(set) lazy var fontSelectorView: FontSelectorView = {
        let selector = FontSelectorView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.selectorDelegate = self
        selector.fontPreviewTextColor = self.options.fontPreviewTextColor
        return selector
    }()

    public private(set) lazy var colorPickerContainerView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .Dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public private(set) lazy var colorPickerView: ColorPickerView = {
        let selector = ColorPickerView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        return selector
    }()

    private var textLabel = UILabel()

    // MAKR: - Initializers

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        InstanceFactory.fontImporter().importFonts()

        fontName = options.defaultFontName

        configureTextClipView()
        configureTextField()
        configureButtons()
        registerForKeyboardNotifications()
        configureGestureRecognizers()
        backupTexts()
        fixedFilterStack.textFilters.removeAll()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rerenderPreviewWithoutText()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        textClipView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
    }

    // MARK: - EditorViewController

    public override var options: TextEditorViewControllerOptions {
        return self.configuration.textEditorViewControllerOptions
    }

    // MARK: - SubEditorViewController

    public override func tappedDone(sender: UIBarButtonItem?) {
        let completeSize = textClipView.bounds.size
        let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
        for view in textClipView.subviews {
            if let label = view as? UILabel {
                print(label.center, completeSize)
                print(label.font)
                print(label.frame.size)
                let textFilter = InstanceFactory.textFilter()
                // swiftlint:disable force_cast
                textFilter.inputImage = self.previewImageView.image!.CIImage
                // swiftlint:enable force_cast
                textFilter.cropRect = cropRect
                var center = CGPoint(x: label.center.x / completeSize.width,
                    y: label.center.y / completeSize.height)
                center.x *= cropRect.width
                center.y *= cropRect.height
                center.x += cropRect.origin.x
                center.y += cropRect.origin.y
                textFilter.fontName = label.font.fontName
                textFilter.text = label.text ?? ""
                textFilter.initialFontSize = label.font.pointSize / previewImageView.visibleImageFrame.size.height
                textFilter.color = label.textColor
                textFilter.transform = label.transform
                textFilter.center = center
                fixedFilterStack.textFilters.append(textFilter)
            }
        }

        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }

    // MARK: - Configuration

    private func configureButtons() {
        // Setup button container view
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: [], metrics: nil, views: ["buttonContainerView": buttonContainerView]))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))

        var views = [String: UIView]()
        var visualFormatString = ""
        if options.canModifyTextColor {
            views = viewsByAddingButton(addTextButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(addTextButton, visualFormatString: visualFormatString)
        }
        if options.canModifyTextFont {
            views = viewsByAddingButton(selectTextFontButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(selectTextFontButton, visualFormatString: visualFormatString)
        }
        if options.canModifyTextColor {
            views = viewsByAddingButton(selectTextColorButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(selectTextColorButton, visualFormatString: visualFormatString)
        }
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 70 ], views: views))
    }

    private func viewsByAddingButton(button: ImageCaptionButton, containerView: UIView, var views: [String: UIView]) -> ([String: UIView]) {
        let viewName = "_\(String(button.hash))"
        containerView.addSubview(button)
        views[viewName] = button
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)]|", options: [], metrics: nil, views: views))
        return views
    }

    private func visualFormatStringByAddingButton(button: ImageCaptionButton, var visualFormatString: String) -> (String) {
        let viewName = "_\(String(button.hash))"
        visualFormatString.appendContentsOf("[\(viewName)(==buttonWidth)]")
        return visualFormatString
    }

    private func configureTextClipView() {
        view.addSubview(textClipView)
    }

    private func configureTextField() {
        view.addSubview(textField)
        textField.frame = CGRect(x: 0, y: view.bounds.size.height, width: view.bounds.size.width, height: kTextFieldHeight)
    }

    private func configureTextLabel() {
        textClipView.addSubview(textLabel)
        textLabel.alpha = 0.0
        textLabel.backgroundColor = UIColor(white:0.0, alpha:0.0)
        textLabel.textColor = self.textColor
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.clipsToBounds = true
        textLabel.userInteractionEnabled = true
        // we set the rotation to 360 degree, so the transform anchor point is set to center
        textLabel.transform = CGAffineTransformRotate(textLabel.transform, CGFloat(M_PI) * 2.0)
    }

    private func configureFontSelectorView() {
        view.addSubview(fontSelectorContainerView)
        fontSelectorContainerView.contentView.addSubview(fontSelectorView)

        let views = [
            "fontSelectorContainerView" : fontSelectorContainerView,
            "fontSelectorView" : fontSelectorView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontSelectorContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[fontSelectorContainerView]|", options: [], metrics: nil, views: views))

        fontSelectorContainerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontSelectorView]|", options: [], metrics: nil, views: views))
        fontSelectorContainerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[fontSelectorView]|", options: [], metrics: nil, views: views))

        fontSelectorContainerView.alpha = 0.0
        UIView.animateWithDuration(0.3) {
            self.fontSelectorContainerView.alpha = 1.0
        }
    }

    private func configureColorPickerView() {
        view.addSubview(colorPickerContainerView)
        colorPickerContainerView.contentView.addSubview(colorPickerView)
        colorPickerView.initialColor = textLabel.textColor
        colorPickerView.pickerDelegate = self

        let views = [
            "colorPickerContainerView" : colorPickerContainerView,
            "colorPickerView" : colorPickerView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[colorPickerContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[colorPickerContainerView]|", options: [], metrics: nil, views: views))

        colorPickerContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[colorPickerView]|", options: [], metrics: nil, views: views))
        colorPickerContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[colorPickerView]|", options: [], metrics: nil, views: views))
        colorPickerContainerView.alpha = 0.0
        UIView.animateWithDuration(0.3) {
            self.colorPickerContainerView.alpha = 1.0
        }
    }

    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    private func configureGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        textClipView.addGestureRecognizer(panGestureRecognizer)

        if options.canModifyTextSize {
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
            pinchGestureRecognizer.delegate = self
            textClipView.addGestureRecognizer(pinchGestureRecognizer)
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGestureRecognizer.delegate = self
        textClipView.addGestureRecognizer(tapGestureRecognizer)

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
        rotationGestureRecognizer.delegate = self
        textClipView.addGestureRecognizer(rotationGestureRecognizer)
    }

    // MARK: - Button Handling

    @objc private func addText(sender: ImageCaptionButton) {
        textField.text = ""
        textField.becomeFirstResponder()
    }

    @objc private func setTextFont(sender: ImageCaptionButton) {
        navigationItem.rightBarButtonItem?.enabled = false
        configureFontSelectorView()
    }

    @objc private func setTextColor(sender: ImageCaptionButton) {
        navigationItem.rightBarButtonItem?.enabled = false
        configureColorPickerView()
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(textClipView)
        let translation = recognizer.translationInView(textClipView)
        switch recognizer.state {
        case .Began:
            draggedView = textClipView.hitTest(location, withEvent: nil) as? UILabel
            if let draggedView = draggedView {
                unSelectTextLabel(textLabel)
                textLabel = draggedView
                selectTextLabel(textLabel)
                textClipView.bringSubviewToFront(draggedView)
            }
        case .Changed:
            if let draggedView = draggedView {
                draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            }
            recognizer.setTranslation(CGPointZero, inView: textClipView)
       case .Cancelled, .Ended:
            draggedView = nil
        default:
            break
       }
    }

    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView:textClipView)
            let point2 = recognizer.locationOfTouch(1, inView:textClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let scale = recognizer.scale

            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = textClipView.hitTest(midpoint, withEvent: nil) as? UILabel
                }

                if let draggedView = draggedView {
                    unSelectTextLabel(textLabel)
                    textLabel = draggedView
                    selectTextLabel(textLabel)
                    textClipView.bringSubviewToFront(draggedView)
                }
            case .Changed:
                if let draggedView =  draggedView {
                    currentTextSize = draggedView.font.pointSize
                    currentTextSize *= scale
                    draggedView.font = UIFont(name: draggedView.font.fontName, size: currentTextSize)
                    draggedView.sizeToFit()
                }
                recognizer.scale = 1
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }

    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: textClipView)
            let point2 = recognizer.locationOfTouch(1, inView: textClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let rotation = recognizer.rotation

            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = textClipView.hitTest(midpoint, withEvent: nil) as? UILabel
                }

                if let draggedView = draggedView {
                    unSelectTextLabel(textLabel)
                    textLabel = draggedView
                    selectTextLabel(textLabel)
                    textClipView.bringSubviewToFront(draggedView)
                }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformRotate(draggedView.transform, rotation)
                }

                recognizer.rotation = 0
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(textClipView)
        draggedView = textClipView.hitTest(location, withEvent: nil) as? UILabel
        unSelectTextLabel(textLabel)
        if let draggedView = draggedView {
            textLabel = draggedView
            currentTextSize = textLabel.font.pointSize
            selectTextLabel(textLabel)
            textClipView.bringSubviewToFront(draggedView)
        }
    }

    // MARK: - Notification Handling

    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        if let frameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = view.convertRect(frameValue.CGRectValue(), fromView: nil)
            textField.frame = CGRect(x: 0, y: view.frame.size.height - keyboardFrame.size.height - kTextFieldHeight, width: view.frame.size.width, height: kTextFieldHeight)
        }
    }

    // MARK: - Helpers

    private func hideTextField() {
        UIView.animateWithDuration(0.2) {
            self.textField.alpha = 0.0
        }
    }

    private func showTextLabel() {
        UIView.animateWithDuration(0.2) {
            self.textLabel.alpha = 1.0
        }
    }

    private func calculateInitialFontSize() {
        // swiftlint:disable force_cast
       let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        if let text = textLabel.text {
            currentTextSize = 1.0
            var size = CGSizeZero
            if !text.isEmpty {
                repeat {
                    currentTextSize += 1.0
                    if let font = UIFont(name: fontName, size: currentTextSize) {
                        size = text.sizeWithAttributes([ NSFontAttributeName: font,  NSParagraphStyleAttributeName:customParagraphStyle])
                    }
                } while ((size.width < (textClipView.frame.size.width - kTextLabelInitialMargin)) && (size.height < (textClipView.frame.size.height - kTextLabelInitialMargin)))
            }
        }
    }

    private func setInitialTextLabelSize() {
        calculateInitialFontSize()
        textLabel.font = UIFont(name: fontName, size: currentTextSize)
        textLabel.sizeToFit()
        textLabel.frame.origin.x = kTextLabelInitialMargin / 2.0 - textClipView.frame.origin.x
        textLabel.frame.origin.y = -textLabel.frame.size.height / 2.0 + textClipView.frame.height / 2.0
    }

    private func calculateNewFontSizeBasedOnDistanceBetweenPoint(point1: CGPoint, and point2: CGPoint) -> CGFloat {
        let diffX = point1.x - point2.x
        let diffY = point1.y - point2.y
        return sqrt(diffX * diffX + diffY  * diffY)
    }

    private func selectTextLabel(label: UILabel) {
        label.layer.borderColor = UIColor.whiteColor().CGColor
        label.layer.borderWidth = 1.0
    }

    private func unSelectTextLabel(label: UILabel) {
        label.layer.borderWidth = 0
    }

    // MARK: - sticker object restore

    private func rerenderPreviewWithoutText() {
        updatePreviewImageWithCompletion { () -> (Void) in
            self.addTextsFromTextFilters(self.tempTextCopy)
        }
    }

    private func backupTexts() {
        tempTextCopy = fixedFilterStack.textFilters
    }


    /*
    * in this method we do some calculations to re calculate the
    * sticker position in relation to the crop region.
    * Therefore we calculte the position and size within the non-cropped image
    * and apply the translation and scaling that comes with cropping in relation
    * to the full image.
    * When we are done we must revoke that extra transformation.
    */
    private func addTextsFromTextFilters(textFilters: [Filter]) {
        for element in textFilters {
            guard let textFilter = element as? TextFilter else {
                return
            }
            let label = UILabel()
            label.userInteractionEnabled = true
            let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
            var completeSize = previewImageView.visibleImageFrame.size
            completeSize.width *= 1.0 / cropRect.width
            completeSize.height *= 1.0 / cropRect.height
            label.font = UIFont(name: textFilter.fontName, size: textFilter.initialFontSize * previewImageView.visibleImageFrame.size.height)
            label.text = textFilter.text
            label.sizeToFit()
            label.transform = textFilter.transform

            var center = CGPoint(x: textFilter.center.x * completeSize.width,
                y: textFilter.center.y * completeSize.height)
            center.x -= cropRect.origin.x
            center.y -= cropRect.origin.y
            center.x /= cropRect.width
            center.y /= cropRect.height

            label.center = center
            print(center, completeSize)
            print(label.frame.size)
            label.clipsToBounds = false
            label.textColor = textFilter.color
            textClipView.addSubview(label)
        }
    }
}

extension TextEditorViewController: TextColorSelectorViewDelegate {
    public func textColorSelectorView(selectorView: TextColorSelectorView, didSelectColor color: UIColor) {
        textColor = color
        textField.textColor = color
        textLabel.textColor = color
    }
}

extension TextEditorViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }

    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideTextField()
        unSelectTextLabel(textLabel)
        textLabel = UILabel()
        configureTextLabel()
        textLabel.text = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        selectTextLabel(textLabel)
        setInitialTextLabelSize()
        showTextLabel()
        navigationItem.rightBarButtonItem?.enabled = true
        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TextEditorViewController: FontSelectorViewDelegate {
    public func fontSelectorView(fontSelectorView: FontSelectorView, didSelectFontWithName fontName: String) {
        UIView.animateWithDuration(0.3, animations: {
            self.fontSelectorContainerView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.fontSelectorContainerView.removeFromSuperview()
        })

        self.fontName = fontName
        if textLabel.layer.borderWidth > 0 {
            textLabel.font = UIFont(name: fontName, size: currentTextSize)
            textLabel.sizeToFit()
        }
    }
}

extension TextEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) || (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        return false
    }
}

extension TextEditorViewController: ColorPickerViewDelegate {
    public func colorPicked(colorPickerView: ColorPickerView, didPickColor color: UIColor) {
        textLabel.textColor = color
        hideColorPicker()
    }

    public func canceledColorPicking(colorPickerView: ColorPickerView) {
        hideColorPicker()
    }

    private func hideColorPicker() {
        UIView.animateWithDuration(0.3, animations: {
            self.colorPickerContainerView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.colorPickerContainerView.removeFromSuperview()
        })
    }
}
