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
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "rotateLeft:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var rotateRightButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.rotate-right", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_rotate-r", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "rotateRight:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var flipHorizontallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-horizontally", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-h", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "flipHorizontally:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var flipVerticallyButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("orientation-editor.flip-vertically", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_orientation_flip-v", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "flipVertically:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    private lazy var transparentRectView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        return view
        }()
    
    private let cropRectComponent = IMGLYInstanceFactory.cropRectComponent()
    private var cropRectLeftBound = CGFloat(0)
    private var cropRectRightBound = CGFloat(0)
    private var cropRectTopBound = CGFloat(0)
    private var cropRectBottomBound = CGFloat(0)
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("orientation-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureButtons()
        configureCropRect()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let cropRect = fixedFilterStack.orientationCropFilter.cropRect
        if cropRect.origin.x != 0 || cropRect.origin.y != 0 ||
            cropRect.size.width != 1.0 || cropRect.size.height != 1.0 {
                updatePreviewImageWithoutCropWithCompletion {
                    self.view.layoutIfNeeded()
                    self.cropRectComponent.present()
                    self.layoutCropRectViews()
                }
        } else {
            layoutCropRectViews()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        transparentRectView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
        reCalculateCropRectBounds()
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
        buttonContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[rotateLeftButton(==buttonWidth)][rotateRightButton(==rotateLeftButton)][flipHorizontallyButton(==rotateLeftButton)][flipVerticallyButton(==rotateLeftButton)]|", options: nil, metrics: metrics, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rotateLeftButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[rotateRightButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flipHorizontallyButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flipVerticallyButton]|", options: nil, metrics: nil, views: views))
        
        // Container Constraints
        
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    
    private func configureCropRect() {
        view.addSubview(transparentRectView)
        cropRectComponent.cropRect = fixedFilterStack.orientationCropFilter.cropRect
        cropRectComponent.setup(transparentRectView, parentView: self.view, showAnchors: false)
    }
    
    // MARK: - Helpers
    
    private func updatePreviewImageWithoutCropWithCompletion(completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        let oldCropRect = fixedFilterStack.orientationCropFilter.cropRect
        fixedFilterStack.orientationCropFilter.cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        updatePreviewImageWithCompletion { () -> (Void) in
            self.fixedFilterStack.orientationCropFilter.cropRect = oldCropRect
            completionHandler?()
        }
    }
    
    // MARK: - Cropping
    
    private func layoutCropRectViews() {
        reCalculateCropRectBounds()
        let viewWidth = cropRectRightBound - cropRectLeftBound
        let viewHeight = cropRectBottomBound - cropRectTopBound
        let x = cropRectLeftBound + viewWidth * fixedFilterStack.orientationCropFilter.cropRect.origin.x
        let y = cropRectTopBound + viewHeight * fixedFilterStack.orientationCropFilter.cropRect.origin.y
        let width = viewWidth * fixedFilterStack.orientationCropFilter.cropRect.size.width
        let height = viewHeight * fixedFilterStack.orientationCropFilter.cropRect.size.height
        let rect = CGRect(x: x, y: y, width: width, height: height)
        cropRectComponent.cropRect = rect
        cropRectComponent.layoutViewsForCropRect()
    }
    
    private func reCalculateCropRectBounds() {
        let width = transparentRectView.frame.size.width
        let height = transparentRectView.frame.size.height
        cropRectLeftBound = (width - previewImageView.visibleImageFrame.size.width) / 2.0
        cropRectRightBound = width - cropRectLeftBound
        cropRectTopBound = (height - previewImageView.visibleImageFrame.size.height) / 2.0
        cropRectBottomBound = height - cropRectTopBound
    }
    
    private func rotateCropRectLeft() {
        moveCropRectMidToOrigin()
        // rotatate
        let tempRect = fixedFilterStack.orientationCropFilter.cropRect
        fixedFilterStack.orientationCropFilter.cropRect.origin.x = tempRect.origin.y
        fixedFilterStack.orientationCropFilter.cropRect.origin.y = -tempRect.origin.x
        fixedFilterStack.orientationCropFilter.cropRect.size.width = tempRect.size.height
        fixedFilterStack.orientationCropFilter.cropRect.size.height = -tempRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    private func rotateCropRectRight() {
        moveCropRectMidToOrigin()
        // rotatate
        let tempRect = fixedFilterStack.orientationCropFilter.cropRect
        fixedFilterStack.orientationCropFilter.cropRect.origin.x = -tempRect.origin.y
        fixedFilterStack.orientationCropFilter.cropRect.origin.y = tempRect.origin.x
        fixedFilterStack.orientationCropFilter.cropRect.size.width = -tempRect.size.height
        fixedFilterStack.orientationCropFilter.cropRect.size.height = tempRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    private func flipCropRectHorizontal() {
        moveCropRectMidToOrigin()
        fixedFilterStack.orientationCropFilter.cropRect.origin.x = -fixedFilterStack.orientationCropFilter.cropRect.origin.x - fixedFilterStack.orientationCropFilter.cropRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    private func flipCropRectVertical() {
        moveCropRectMidToOrigin()
        fixedFilterStack.orientationCropFilter.cropRect.origin.y = -fixedFilterStack.orientationCropFilter.cropRect.origin.y - fixedFilterStack.orientationCropFilter.cropRect.size.height
        moveCropRectTopLeftToOrigin()
    }
    
    private func moveCropRectMidToOrigin() {
        fixedFilterStack.orientationCropFilter.cropRect.origin.x -= 0.5
        fixedFilterStack.orientationCropFilter.cropRect.origin.y -= 0.5
    }
    
    private func moveCropRectTopLeftToOrigin() {
        fixedFilterStack.orientationCropFilter.cropRect.origin.x += 0.5
        fixedFilterStack.orientationCropFilter.cropRect.origin.y += 0.5
    }

    // MARK: - Actions
    
    @objc private func rotateLeft(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateLeft()
        rotateCropRectLeft()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
            self.layoutCropRectViews()
        }
    }
    
    @objc private func rotateRight(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.rotateRight()
        rotateCropRectRight()
        updatePreviewImageWithoutCropWithCompletion {
            self.view.layoutIfNeeded()
            self.layoutCropRectViews()
        }
    }
    
    @objc private func flipHorizontally(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipHorizontal()
        flipCropRectHorizontal()
        updatePreviewImageWithoutCropWithCompletion {
            self.layoutCropRectViews()
        }
    }
    
    @objc private func flipVertically(sender: IMGLYImageCaptionButton) {
        fixedFilterStack.orientationCropFilter.flipVertical()
        flipCropRectVertical()
        updatePreviewImageWithoutCropWithCompletion {
            self.layoutCropRectViews()
        }
    }
}
