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

    /// Enables/Disables color changes through the bottom drawer. Defaults to true.
    public let canModifyTextColor: Bool

    /// Enables/Disables font changes through the bottom drawer. Defaults to true.
    public let canModifyTextFont: Bool

    public convenience init() {
        self.init(builder: TextEditorViewControllerOptionsBuilder())
    }

    public init(builder: TextEditorViewControllerOptionsBuilder) {
        textFieldConfigurationClosure = builder.textFieldConfigurationClosure
        fontPreviewTextColor = builder.fontPreviewTextColor
        availableFontColors = builder.availableFontColors
        canModifyTextSize = builder.canModifyTextSize
        canModifyTextColor = builder.canModifyTextColor
        canModifyTextFont = builder.canModifyTextFont
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

    /// Enables/Disables font changes through the bottom drawer. Defaults to true.
    public let canModifyTextFont = true

    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = NSLocalizedString("text-editor.title", tableName: nil, bundle: NSBundle(forClass: MainEditorViewController.self), value: "", comment: "")
    }
}

@objc(IMGLYTextEditorViewController) public class TextEditorViewController: SubEditorViewController {

    // MARK: - Properties

    private var textColor = UIColor.whiteColor()
    private var fontName = ""
    private var currentTextSize = CGFloat(0)
    private var maximumFontSize = CGFloat(0)
    private var panOffset = CGPointZero
    private var fontSizeAtPinchBegin = CGFloat(0)
    private var distanceAtPinchBegin = CGFloat(0)
    private var beganTwoFingerPitch = false
    private var draggedView: UILabel?

    public private(set) lazy var addTextButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = ImageCaptionButton()
        button.textLabel.text = NSLocalizedString("crop-editor.free", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "activateFreeRatio:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var textColorSelectorView: TextColorSelectorView = {
        let view = TextColorSelectorView(availableColors: self.options.availableFontColors)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.currentBackgroundColor
        view.menuDelegate = self
        return view
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

    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        label.backgroundColor = UIColor(white:0.0, alpha:0.0)
        label.textColor = self.textColor
        label.textAlignment = NSTextAlignment.Center
        label.clipsToBounds = true
        label.userInteractionEnabled = true
        return label
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

    // MAKR: - Initializers

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        InstanceFactory.fontImporter().importFonts()

        navigationItem.rightBarButtonItem?.enabled = false

        if options.canModifyTextColor {
        //    configureColorSelectorView()
        }

        configureTextClipView()
        configureTextField()
        configureTextLabel()
        configureButtons()
       // configureFontSelectorView()
        registerForKeyboardNotifications()
        configureGestureRecognizers()
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
        if fixedFilterStack.textFilters.count == 0 {
            fixedFilterStack.textFilters.append(InstanceFactory.textFilter())
        }

        // swiftlint:disable force_cast
        let textFilter = fixedFilterStack.textFilters.first as! TextFilter
        textFilter.inputImage = self.previewImageView.image!.CIImage
        // swiftlint:enable force_cast
        textFilter.cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
        let cropRect = textFilter.cropRect
        let completeSize = textClipView.bounds.size
        var center = CGPoint(x: textLabel.center.x / completeSize.width,
            y: textLabel.center.y / completeSize.height)
        center.x *= cropRect.width
        center.y *= cropRect.height
        center.x += cropRect.origin.x
        center.y += cropRect.origin.y
        textFilter.fontName = fontName
        textFilter.text = textLabel.text ?? ""
        textFilter.initialFontSize = currentTextSize / previewImageView.visibleImageFrame.size.height
        let inputImage = previewImageView.image!
        var size = initialSizeForTextImage(textFilter.textImageSizeFromImageSize(inputImage.size))
        size.width = size.width / completeSize.width
        size.height = size.height / completeSize.height

        let ratio = completeSize.height / completeSize.width
        // Since we use width based scaling, we must set another factor when the string
        // image is taller than wide.
        let scale = size.height < size.width ? size.width : size.width * ratio

        textFilter.color = textColor
        textFilter.transform = textLabel.transform
        textFilter.center = center
        textFilter.scale = scale

        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }

    private func initialSizeForTextImage(size: CGSize) -> CGSize {
        let initialMaxStickerSize = (CGRectGetWidth(textClipView.bounds) - kTextLabelInitialMargin) * self.fixedFilterStack.orientationCropFilter.cropRect.width
        let widthRatio = initialMaxStickerSize / size.width
        let heightRatio = initialMaxStickerSize / size.height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: size.width * scale, height: size.height * scale)
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
            let viewName = "_\(String(addTextButton.hash))"
            visualFormatString.appendContentsOf("[\(viewName)(==buttonWidth)]")
            buttonContainerView.addSubview(addTextButton)
            views[viewName] = addTextButton
            print(viewName)
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)]|", options: [], metrics: nil, views: views))

        }
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 70 ], views: views))
    }

    private func configureColorSelectorView() {
        bottomContainerView.addSubview(textColorSelectorView)

        let views = [
            "textColorSelectorView" : textColorSelectorView
        ]

        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textColorSelectorView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textColorSelectorView]|", options: [], metrics: nil, views: views))
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

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
        rotationGestureRecognizer.delegate = self
        textClipView.addGestureRecognizer(rotationGestureRecognizer)
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(textClipView)
        let translation = recognizer.translationInView(textClipView)
        switch recognizer.state {
        case .Began:
            draggedView = textClipView.hitTest(location, withEvent: nil) as? UILabel
            if let draggedView = draggedView {
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
                    textClipView.bringSubviewToFront(draggedView)
              }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformScale(draggedView.transform, scale, scale)
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

    private func updateTextLabelFrameForCurrentFont() {
        // resize and keep the text centered
        let frame = textLabel.frame
        textLabel.sizeToFit()

        let diffX = frame.size.width - textLabel.frame.size.width
        let diffY = frame.size.height - textLabel.frame.size.height
        textLabel.frame.origin.x += (diffX / 2.0)
        textLabel.frame.origin.y += (diffY / 2.0)
    }

    private func transformedTextFrame() -> CGRect {
        var origin = textLabel.frame.origin
        origin.x = origin.x / previewImageView.visibleImageFrame.size.width
        origin.y = origin.y / previewImageView.visibleImageFrame.size.height

        var size = textLabel.frame.size
        size.width = size.width / textLabel.frame.size.width
        size.height = size.height / textLabel.frame.size.height

        return CGRect(origin: origin, size: size)
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
        textLabel.text = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
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
        fontSelectorContainerView.removeFromSuperview()
        self.fontName = fontName
        textField.font = UIFont(name: fontName, size: kFontSizeInTextField)
        textField.becomeFirstResponder()
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
