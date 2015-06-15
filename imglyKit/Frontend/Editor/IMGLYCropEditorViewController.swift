//
//  IMGLYCropEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYSelectionMode: Int {
    case Free
    case OneToOne
    case FourToThree
    case SixteenToNine
}

public let MinimumCropSize = CGFloat(50)

public class IMGLYCropEditorViewController: IMGLYSubEditorViewController {

    // MARK: - Properties
    
    public private(set) lazy var freeRatioButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("crop-editor.free", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "activateFreeRatio:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var oneToOneRatioButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("crop-editor.1-to-1", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_square", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "activateOneToOneRatio:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var fourToThreeRatioButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("crop-editor.4-to-3", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_4-3", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "activateFourToThreeRatio:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var sixteenToNineRatioButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("crop-editor.16-to-9", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_crop_16-9", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "activateSixteenToNineRatio:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    private var selectedButton: IMGLYImageCaptionButton? {
        willSet(newSelectedButton) {
            self.selectedButton?.selected = false
        }
        
        didSet {
            self.selectedButton?.selected = true
        }
    }
    
    private lazy var transparentRectView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        return view
        }()
    
    private let cropRectComponent = IMGLYInstanceFactory.cropRectComponent()
    public var selectionMode = IMGLYSelectionMode.Free
    public var selectionRatio = CGFloat(1.0)
    private var cropRectLeftBound = CGFloat(0)
    private var cropRectRightBound = CGFloat(0)
    private var cropRectTopBound = CGFloat(0)
    private var cropRectBottomBound = CGFloat(0)
    private var dragOffset = CGPointZero

    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("crop-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureButtons()
        configureCropRect()
        selectedButton = freeRatioButton
    }
    
    public override func viewDidAppear(animated: Bool) {
        let cropRect = fixedFilterStack.orientationCropFilter.cropRect
        if cropRect.origin.x != 0 || cropRect.origin.y != 0 ||
            cropRect.size.width != 1.0 || cropRect.size.height != 1.0 {
                updatePreviewImageWithoutCropWithCompletion {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                    self.reCalculateCropRectBounds()
                    self.setInitialCropRect()
                    self.cropRectComponent.present()
                }
        } else {
            reCalculateCropRectBounds()
            setInitialCropRect()
            cropRectComponent.present()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        transparentRectView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
        reCalculateCropRectBounds()
    }
    
    // MARK: - SubEditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        fixedFilterStack.orientationCropFilter.cropRect = normalizedCropRect()
        
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }
    
    // MARK: - Configuration
    
    private func configureButtons() {
        let buttonContainerView = UIView()
        buttonContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomContainerView.addSubview(buttonContainerView)
        
        buttonContainerView.addSubview(freeRatioButton)
        buttonContainerView.addSubview(oneToOneRatioButton)
        buttonContainerView.addSubview(fourToThreeRatioButton)
        buttonContainerView.addSubview(sixteenToNineRatioButton)
        
        let views = [
            "buttonContainerView" : buttonContainerView,
            "freeRatioButton" : freeRatioButton,
            "oneToOneRatioButton" : oneToOneRatioButton,
            "fourToThreeRatioButton" : fourToThreeRatioButton,
            "sixteenToNineRatioButton" : sixteenToNineRatioButton
        ]
        
        let metrics = [
            "buttonWidth" : 70
        ]
        
        // Button Constraints
        
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[freeRatioButton(==buttonWidth)][oneToOneRatioButton(==freeRatioButton)][fourToThreeRatioButton(==freeRatioButton)][sixteenToNineRatioButton(==freeRatioButton)]|", options: nil, metrics: metrics, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[freeRatioButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[oneToOneRatioButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[fourToThreeRatioButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sixteenToNineRatioButton]|", options: nil, metrics: nil, views: views))
        
        // Container Constraints
        
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    
    private func configureCropRect() {
        view.addSubview(transparentRectView)
        cropRectComponent.cropRect = fixedFilterStack.orientationCropFilter.cropRect
        cropRectComponent.setup(transparentRectView, parentView: self.view, showAnchors: true)
        addGestureRecognizerToTransparentView()
        addGestureRecognizerToAnchors()
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
    
    private func addGestureRecognizerToTransparentView() {
        transparentRectView.userInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        transparentRectView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addGestureRecognizerToAnchors() {
        addGestureRecognizerToAnchor(cropRectComponent.topLeftAnchor_!)
        addGestureRecognizerToAnchor(cropRectComponent.topRightAnchor_!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomRightAnchor_!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomLeftAnchor_!)
    }
    
    private func addGestureRecognizerToAnchor(anchor: UIImageView) {
        anchor.userInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        anchor.addGestureRecognizer(panGestureRecognizer)
    }
    
    public func handlePan(recognizer:UIPanGestureRecognizer) {
        if recognizer.view!.isEqual(cropRectComponent.topRightAnchor_) {
            handlePanOnTopRight(recognizer)
        }
        else if recognizer.view!.isEqual(cropRectComponent.topLeftAnchor_) {
            handlePanOnTopLeft(recognizer)
        }
        else if recognizer.view!.isEqual(cropRectComponent.bottomLeftAnchor_) {
            handlePanOnBottomLeft(recognizer)
        }
        else if recognizer.view!.isEqual(cropRectComponent.bottomRightAnchor_) {
            handlePanOnBottomRight(recognizer)
        }
        else if recognizer.view!.isEqual(transparentRectView) {
            handlePanOnTransparentView(recognizer)
        }
    }
    
    public func handlePanOnTopLeft(recognizer:UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.bottomRightAnchor_!.center.x - location.x
        var sizeY = cropRectComponent.bottomRightAnchor_!.center.y - location.y
        
        sizeX = CGFloat(Int(sizeX))
        sizeY = CGFloat(Int(sizeY))
        var size = CGSizeMake(sizeX, sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForTopLeftAnchor(size)
        var center = cropRectComponent.topLeftAnchor_!.center
        center.x += (cropRectComponent.cropRect.size.width - size.width)
        center.y += (cropRectComponent.cropRect.size.height - size.height)
        cropRectComponent.topLeftAnchor_!.center = center
        recalculateCropRectFromTopLeftAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }
    
    private func reCalulateSizeForTopLeftAnchor(size:CGSize) -> CGSize {
        var newSize = size
        if selectionMode != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / selectionRatio
            
            if (cropRectComponent.bottomRightAnchor_!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.bottomRightAnchor_!.center.x - cropRectLeftBound
                newSize.height = newSize.width / selectionRatio
            }
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound
                newSize.width = newSize.height * selectionRatio
            }
        }
        else {
            if (cropRectComponent.bottomRightAnchor_!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.bottomRightAnchor_!.center.x - cropRectLeftBound
            }
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound
            }
        }
        return newSize
    }
    
    private func recalculateCropRectFromTopLeftAnchor() {
        cropRectComponent.cropRect = CGRectMake(cropRectComponent.topLeftAnchor_!.center.x,
            cropRectComponent.topLeftAnchor_!.center.y,
            cropRectComponent.bottomRightAnchor_!.center.x - cropRectComponent.topLeftAnchor_!.center.x,
            cropRectComponent.bottomRightAnchor_!.center.y - cropRectComponent.topLeftAnchor_!.center.y)
    }
    
    private func handlePanOnTopRight(recognizer:UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.bottomLeftAnchor_!.center.x - location.x
        var sizeY = cropRectComponent.bottomLeftAnchor_!.center.y - location.y
        
        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSizeMake(sizeX, sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForTopRightAnchor(size)
        var center = cropRectComponent.topRightAnchor_!.center
        center.x = (cropRectComponent.bottomLeftAnchor_!.center.x + size.width)
        center.y = (cropRectComponent.bottomLeftAnchor_!.center.y - size.height)
        cropRectComponent.topRightAnchor_!.center = center
        recalculateCropRectFromTopRightAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }
    
    private func reCalulateSizeForTopRightAnchor(size:CGSize) -> CGSize {
        var newSize = size
        if selectionMode != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor_!.center.x
            }
            newSize.height = newSize.width / selectionRatio
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound
                newSize.width = newSize.height * selectionRatio
            }
        }
        else {
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor_!.center.x;
            }
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound {
                newSize.height =  cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound
            }
        }
        return newSize
    }
    
    private func recalculateCropRectFromTopRightAnchor() {
        cropRectComponent.cropRect = CGRectMake(cropRectComponent.bottomLeftAnchor_!.center.x,
            cropRectComponent.topRightAnchor_!.center.y,
            cropRectComponent.topRightAnchor_!.center.x - cropRectComponent.bottomLeftAnchor_!.center.x,
            cropRectComponent.bottomLeftAnchor_!.center.y - cropRectComponent.topRightAnchor_!.center.y)
    }
    
    
    private func handlePanOnBottomLeft(recognizer:UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.topRightAnchor_!.center.x - location.x
        var sizeY = cropRectComponent.topRightAnchor_!.center.y - location.y
        
        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSizeMake(sizeX, sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForBottomLeftAnchor(size)
        var center = cropRectComponent.bottomLeftAnchor_!.center
        center.x = (cropRectComponent.topRightAnchor_!.center.x - size.width)
        center.y = (cropRectComponent.topRightAnchor_!.center.y + size.height)
        cropRectComponent.bottomLeftAnchor_!.center = center
        recalculateCropRectFromTopRightAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }
    
    private func reCalulateSizeForBottomLeftAnchor(size:CGSize) -> CGSize {
        var newSize = size
        if selectionMode != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio
            if (newSize.height > newSize.width) {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / selectionRatio
            
            if (cropRectComponent.topRightAnchor_!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.topRightAnchor_!.center.x - cropRectLeftBound
                newSize.height = newSize.width / selectionRatio
            }
            
            if (cropRectComponent.topRightAnchor_!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topRightAnchor_!.center.y
                newSize.width = newSize.height * selectionRatio
            }
        }
        else {
            if (cropRectComponent.topRightAnchor_!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.topRightAnchor_!.center.x - cropRectLeftBound
            }
            if (cropRectComponent.topRightAnchor_!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topRightAnchor_!.center.y
            }
        }
        return newSize
    }
    
    private func handlePanOnBottomRight(recognizer:UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.topLeftAnchor_!.center.x - location.x
        var sizeY = cropRectComponent.topLeftAnchor_!.center.y - location.y
        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSizeMake(sizeX, sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForBottomRightAnchor(size)
        var center = cropRectComponent.bottomRightAnchor_!.center
        center.x -= (cropRectComponent.cropRect.size.width - size.width)
        center.y -= (cropRectComponent.cropRect.size.height - size.height)
        cropRectComponent.bottomRightAnchor_!.center = center
        recalculateCropRectFromTopLeftAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }
    
    private func reCalulateSizeForBottomRightAnchor(size:CGSize) -> CGSize {
        var newSize = size
        if selectionMode != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor_!.center.x;
            }
            newSize.height = newSize.width / selectionRatio
            if (cropRectComponent.topLeftAnchor_!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topLeftAnchor_!.center.y
                newSize.width = newSize.height * selectionRatio
            }
        }
        else {
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor_!.center.x
            }
            if (cropRectComponent.topLeftAnchor_!.center.y + newSize.height) >  cropRectBottomBound {
                newSize.height =  cropRectBottomBound - cropRectComponent.topLeftAnchor_!.center.y
            }
        }
        return newSize
    }
    
    private func handlePanOnTransparentView(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        if cropRectComponent.cropRect.contains(location) {
            calculateDragOffsetOnNewDrag(recognizer:recognizer)
            let newLocation = clampedLocationToBounds(location)
            var rect = cropRectComponent.cropRect
            rect.origin.x = newLocation.x - dragOffset.x
            rect.origin.y = newLocation.y - dragOffset.y
            cropRectComponent.cropRect = rect
            cropRectComponent.layoutViewsForCropRect()
        }
    }
    
    private func calculateDragOffsetOnNewDrag(#recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        if recognizer.state == UIGestureRecognizerState.Began {
            dragOffset = CGPointMake(location.x - cropRectComponent.cropRect.origin.x, location.y - cropRectComponent.cropRect.origin.y)
        }
    }
    
    private func clampedLocationToBounds(location: CGPoint) -> CGPoint {
        let rect = cropRectComponent.cropRect
        var locationX = location.x
        var locationY = location.y
        let left = locationX - dragOffset.x
        let right = left + rect.size.width
        let top  = locationY - dragOffset.y
        let bottom = top + rect.size.height
        
        if left < cropRectLeftBound {
            locationX = cropRectLeftBound + dragOffset.x
        }
        if right > cropRectRightBound {
            locationX = cropRectRightBound - cropRectComponent.cropRect.size.width  + dragOffset.x
        }
        if top < cropRectTopBound {
            locationY = cropRectTopBound + dragOffset.y
        }
        if bottom > cropRectBottomBound {
            locationY = cropRectBottomBound - cropRectComponent.cropRect.size.height + dragOffset.y
        }
        return CGPointMake(locationX, locationY)
    }
    
    private func normalizedCropRect() -> CGRect {
        reCalculateCropRectBounds()
        let boundWidth = cropRectRightBound - cropRectLeftBound
        let boundHeight = cropRectBottomBound - cropRectTopBound
        let x = (cropRectComponent.cropRect.origin.x - cropRectLeftBound) / boundWidth
        let y = (cropRectComponent.cropRect.origin.y - cropRectTopBound) / boundHeight
        return CGRectMake(x, y, cropRectComponent.cropRect.size.width / boundWidth, cropRectComponent.cropRect.size.height / boundHeight)
    }
    
    private func reCalculateCropRectBounds() {
        let width = transparentRectView.frame.size.width
        let height = transparentRectView.frame.size.height
        cropRectLeftBound = (width - previewImageView.visibleImageFrame.size.width) / 2.0
        cropRectRightBound = width - cropRectLeftBound
        cropRectTopBound = (height - previewImageView.visibleImageFrame.size.height) / 2.0
        cropRectBottomBound = height - cropRectTopBound
    }
    
    private func applyMinimumAreaRuleToSize(size:CGSize) -> CGSize {
        var newSize = size
        if newSize.width < MinimumCropSize {
            newSize.width = MinimumCropSize
        }
        
        if newSize.height < MinimumCropSize {
            newSize.height = MinimumCropSize
        }
        return newSize
    }
    
    private func setInitialCropRect() {
        selectionRatio = 1.0
        setCropRectForSelectionRatio()
    }
    
    private func setCropRectForSelectionRatio() {
        let size = CGSizeMake(cropRectRightBound - cropRectLeftBound,
            cropRectBottomBound - cropRectTopBound)
        var rectWidth = size.width
        var rectHeight = rectWidth
        if size.width > size.height {
            rectHeight = size.height
            rectWidth = rectHeight
        }
        rectHeight /= selectionRatio
        
        let sizeDeltaX = (size.width - rectWidth) / 2.0
        let sizeDeltaY = (size.height - rectHeight) / 2.0
        
        cropRectComponent.cropRect = CGRectMake(
            cropRectLeftBound  + sizeDeltaX,
            cropRectTopBound + sizeDeltaY,
            rectWidth,
            rectHeight)
    }
    
    private func calculateRatioForSelectionMode() {
        if selectionMode == IMGLYSelectionMode.FourToThree {
            selectionRatio = 4.0 / 3.0
        }
        else if selectionMode == IMGLYSelectionMode.OneToOne {
            selectionRatio = 1.0
        }
        else if selectionMode == IMGLYSelectionMode.SixteenToNine {
            selectionRatio = 16.0 / 9.0
        }
        if selectionMode != IMGLYSelectionMode.Free {
            setCropRectForSelectionRatio()
            cropRectComponent.layoutViewsForCropRect()
        }
    }
    
    // MARK: - Actions
    
    @objc private func activateFreeRatio(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectionMode = IMGLYSelectionMode.Free
        calculateRatioForSelectionMode()
        
        selectedButton = sender
    }
    
    @objc private func activateOneToOneRatio(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectionMode = IMGLYSelectionMode.OneToOne
        calculateRatioForSelectionMode()
        
        selectedButton = sender
    }
    
    @objc private func activateFourToThreeRatio(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectionMode = IMGLYSelectionMode.FourToThree
        calculateRatioForSelectionMode()
        
        selectedButton = sender
    }
    
    @objc private func activateSixteenToNineRatio(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectionMode = IMGLYSelectionMode.SixteenToNine
        calculateRatioForSelectionMode()
        
        selectedButton = sender
    }
}

