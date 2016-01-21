//
//  OrientationEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum OrientationAction: Int {
    case RotateLeft
    case RotateRight
    case FlipHorizontally
    case FlipVertically
}

@objc(IMGLYOrientationEditorViewController) public class OrientationEditorViewController: SubEditorViewController {

    // MARK: - Properties

    public private(set) lazy var rotateLeftButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: OrientationEditorViewController.self)
        let button = ImageCaptionButton()
        button.textLabel.text = Localize("Rotate L")
        button.accessibilityLabel = Localize("Rotate left")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-l", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateLeft:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .RotateLeft)
        return button
        }()

    public private(set) lazy var rotateRightButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: OrientationEditorViewController.self)
        let button = ImageCaptionButton()
        button.textLabel.text = Localize("Rotate R")
        button.accessibilityLabel = Localize("Rotate right")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-r", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateRight:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .RotateRight)
        return button
        }()

    public private(set) lazy var flipHorizontallyButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: OrientationEditorViewController.self)
        let button = ImageCaptionButton()
        button.textLabel.text = Localize("Flip H")
        button.accessibilityLabel = Localize("Flip horizontally")
        button.imageView.image = UIImage(named: "icon_orientation_flip-h", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipHorizontally:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .FlipHorizontally)
        return button
        }()

    public private(set) lazy var flipVerticallyButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: OrientationEditorViewController.self)
        let button = ImageCaptionButton()
        button.textLabel.text = Localize("Flip V")
        button.accessibilityLabel = Localize("Flip vertically")
        button.imageView.image = UIImage(named: "icon_orientation_flip-v", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipVertically:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .FlipVertically)
        return button
        }()


    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureButtons()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let cropRect = fixedFilterStack.orientationCropFilter.cropRect
        if cropRect.origin.x != 0 || cropRect.origin.y != 0 ||
            cropRect.size.width != 1.0 || cropRect.size.height != 1.0 {
                updatePreviewImageWithoutCropWithCompletion {
                    self.view.layoutIfNeeded()
                }
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - EditorViewController

    public override var options: OrientationEditorViewControllerOptions {
        return self.configuration.orientationEditorViewControllerOptions
    }

    // MARK: - SubEditorViewController

    public override func tappedDone(sender: UIBarButtonItem?) {
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }

    // MARK: - Configuration

    private func configureButtons() {
        // Map actions and buttons
        let actionToButtonMap: [OrientationAction: ImageCaptionButton] = [
            .RotateLeft: rotateLeftButton,
            .RotateRight: rotateRightButton,
            .FlipHorizontally: flipHorizontallyButton,
            .FlipVertically: flipVerticallyButton
        ]

        // Setup button container view
        let buttonContainerView = UIView()
        buttonContainerView.backgroundColor = currentBackgroundColor
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: [], metrics: nil, views: ["buttonContainerView": buttonContainerView]))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))

        var views = [String: UIView]()
        var viewNames = [String]()
        for action in options.allowedOrientationActions {
            let button = actionToButtonMap[action]!
            let viewName = "_\(String(abs(button.hash)))" // View names must start with a letter or underscore
            viewNames.append(viewName)
            buttonContainerView.addSubview(button)
            views[viewName] = button
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)]|", options: [], metrics: nil, views: views))
        }

        // Button Constraints
        let visualFormatString = viewNames.reduce("") { (acc, name) -> String in
            return acc + "[\(name)(==buttonWidth)]"
        }
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 70 ], views: views))
    }

    // MARK: - Helpers

    private func updatePreviewImageWithoutCropWithCompletion(completionHandler: PreviewImageGenerationCompletionBlock?) {
        updatePreviewImageWithCompletion { () -> (Void) in
            completionHandler?()
        }
    }

    // MARK: - Actions

    @objc private func rotateLeft(sender: ImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateLeft()
        fixedFilterStack.rotateStickersLeft()
        fixedFilterStack.rotateTextLeft()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func rotateRight(sender: ImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateRight()
        fixedFilterStack.rotateStickersRight()
        fixedFilterStack.rotateTextRight()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func flipHorizontally(sender: ImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipHorizontal()
        fixedFilterStack.flipStickersHorizontal()
        fixedFilterStack.flipTextHorizontal()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }

    @objc private func flipVertically(sender: ImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipVertical()
        fixedFilterStack.flipStickersVertical()
        fixedFilterStack.flipTextVertical()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
}
