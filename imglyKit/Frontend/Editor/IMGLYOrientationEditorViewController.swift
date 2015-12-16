//
//  IMGLYOrientationEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit


@objc public class IMGLYOrientationEditorViewControllerOptions: IMGLYEditorViewControllerOptions {
    
    public typealias IMGLYOrientationActionButtonConfigurationClosure = (IMGLYImageCaptionButton, IMGLYOrientationAction) -> ()

    // MARK: Behaviour
    
    /// Defines all allowed actions. The action buttons are always shown in the rotate -> flip order.
    /// Defaults to show all available actions.
    public var allowedOrientationActions: [IMGLYOrientationAction] = [ .RotateLeft, .RotateRight, .FlipHorizontally, .FlipVertically ]
    
    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: IMGLYOrientationActionButtonConfigurationClosure = { _ in }
    
    public override init() {
        super.init()
        
        /// Override inherited properties with default values
        self.title = NSLocalizedString("orientation-editor.title", tableName: nil, bundle: NSBundle(forClass: IMGLYMainEditorViewController.self), value: "", comment: "")
    }
}

public class IMGLYOrientationEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public private(set) lazy var rotateLeftButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-left", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-l", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateLeft:", forControlEvents: .TouchUpInside)
        self.configuration.orientationEditorViewControllerOptions.actionButtonConfigurationClosure(button, .RotateLeft)
        return button
        }()
    
    public private(set) lazy var rotateRightButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-right", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-r", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateRight:", forControlEvents: .TouchUpInside)
        self.configuration.orientationEditorViewControllerOptions.actionButtonConfigurationClosure(button, .RotateRight)
        return button
        }()
    
    public private(set) lazy var flipHorizontallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-horizontally", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-h", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipHorizontally:", forControlEvents: .TouchUpInside)
        self.configuration.orientationEditorViewControllerOptions.actionButtonConfigurationClosure(button, .FlipHorizontally)
        return button
        }()
    
    public private(set) lazy var flipVerticallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: IMGLYOrientationEditorViewController.self)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-vertically", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-v", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipVertically:", forControlEvents: .TouchUpInside)
        self.configuration.orientationEditorViewControllerOptions.actionButtonConfigurationClosure(button, .FlipVertically)
        return button
        }()
    
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = self.configuration.orientationEditorViewControllerOptions.title
        
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
    
    // MARK: - IMGLYEditorViewController
    
    public override var enableZoomingInPreviewImage: Bool {
        return true
    }
    
    // MARK: - SubEditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }
    
    // MARK: - Configuration
    
    private func configureButtons() {
        var views = [String: UIView]()

        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        
        let allowedActions = configuration.orientationEditorViewControllerOptions.allowedOrientationActions
        if allowedActions.contains(.RotateLeft) {
            buttonContainerView.addSubview(rotateLeftButton)
            views["rotateLeftButton"] = rotateLeftButton
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rotateLeftButton]|", options: [], metrics: nil, views: views))
        }
        
        if allowedActions.contains(.RotateRight) {
            buttonContainerView.addSubview(rotateRightButton)
            views["rotateRightButton"] = rotateRightButton
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rotateRightButton]|", options: [], metrics: nil, views: views))
        }
        
        if allowedActions.contains(.FlipHorizontally) {
            buttonContainerView.addSubview(flipHorizontallyButton)
            views["flipHorizontallyButton"] = flipHorizontallyButton
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flipHorizontallyButton]|", options: [], metrics: nil, views: views))
        }
        
        if allowedActions.contains(.FlipVertically) {
            buttonContainerView.addSubview(flipVerticallyButton)
            views["flipVerticallyButton"] = flipVerticallyButton
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flipVerticallyButton]|", options: [], metrics: nil, views: views))
        }
        
        let metrics = [
            "buttonWidth" : 70
        ]
        
        var visualFormatString = "|"
        for key in views.keys {
            visualFormatString += "[\(key)(==buttonWidth)]"
        }
        visualFormatString += "|"
        
        // Button Constraints
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(visualFormatString, options: [], metrics: metrics, views: views))
        
        // Container Constraints
        views["buttonContainerView"] = buttonContainerView
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    
    
    // MARK: - Helpers
    
    private func updatePreviewImageWithoutCropWithCompletion(completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        updatePreviewImageWithCompletion { () -> (Void) in
            completionHandler?()
        }
    }
    
    // MARK: - Actions
    
    @objc private func rotateLeft(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateLeft()
        fixedFilterStack.rotateStickersLeft()
        fixedFilterStack.rotateTextLeft()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func rotateRight(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateRight()
        fixedFilterStack.rotateStickersRight()
        fixedFilterStack.rotateTextRight()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func flipHorizontally(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipHorizontal()
        fixedFilterStack.flipStickersHorizontal()
        fixedFilterStack.flipTextHorizontal()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
    
    @objc private func flipVertically(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipVertical()
        fixedFilterStack.flipStickersVertical()
        fixedFilterStack.flipTextVertical()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
}
