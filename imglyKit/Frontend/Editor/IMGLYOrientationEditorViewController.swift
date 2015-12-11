//
//  IMGLYOrientationEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYOrientationEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public private(set) lazy var rotateLeftButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-left", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-l", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateLeft:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var rotateRightButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-right", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-r", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "rotateRight:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var flipHorizontallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-horizontally", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-h", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipHorizontally:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var flipVerticallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-vertically", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-v", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipVertically:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("orientation-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
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
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        
        buttonContainerView.addSubview(rotateLeftButton)
        buttonContainerView.addSubview(rotateRightButton)
        buttonContainerView.addSubview(flipHorizontallyButton)
        buttonContainerView.addSubview(flipVerticallyButton)
        
        let views = [
            "buttonContainerView" : buttonContainerView,
            "rotateLeftButton" : rotateLeftButton,
            "rotateRightButton" : rotateRightButton,
            "flipHorizontallyButton" : flipHorizontallyButton,
            "flipVerticallyButton" : flipVerticallyButton
        ]
        
        let metrics = [
            "buttonWidth" : 70
        ]
        
        // Button Constraints
        
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[rotateLeftButton(==buttonWidth)][rotateRightButton(==rotateLeftButton)][flipHorizontallyButton(==rotateLeftButton)][flipVerticallyButton(==rotateLeftButton)]|", options: [], metrics: metrics, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rotateLeftButton]|", options: [], metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rotateRightButton]|", options: [], metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flipHorizontallyButton]|", options: [], metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flipVerticallyButton]|", options: [], metrics: nil, views: views))
        
        // Container Constraints
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
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func rotateRight(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateRight()
        fixedFilterStack.rotateStickersRight()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func flipHorizontally(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipHorizontal()
        fixedFilterStack.flipStickersHorizontal()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
    
    @objc private func flipVertically(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipVertical()
        fixedFilterStack.flipStickersVertical()
        updatePreviewImageWithoutCropWithCompletion {
        }
    }
}
