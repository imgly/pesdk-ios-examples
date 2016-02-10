//
//  CropEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public let kMinimumCropSize = CGFloat(50)

@objc(IMGLYCropEditorViewController) public class CropEditorViewController: SubEditorViewController {

    // MARK: - Properties

    private var selectedButton: ImageCaptionButton? {
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

    private lazy var scrollView: CenteredScrollView = {
        let scrollView = CenteredScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private var cropRatioToButton = [CropRatio: ImageCaptionButton]()
    private let cropRectComponent = InstanceFactory.cropRectComponent()
    public var selectionMode: CropRatio?
    private var cropRectLeftBound = CGFloat(0)
    private var cropRectRightBound = CGFloat(0)
    private var cropRectTopBound = CGFloat(0)
    private var cropRectBottomBound = CGFloat(0)
    private var dragOffset = CGPoint.zero

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = options.title

        if let firstCropAction = options.allowedCropRatios.first {
            selectionMode = firstCropAction
        }

        configureButtons()
        configureCropRect()
        configureScrollView()
    }

    public override func viewDidAppear(animated: Bool) {
        let cropRect = fixedFilterStack.orientationCropFilter.cropRect
        if cropRect.origin.x != 0 || cropRect.origin.y != 0 ||
            cropRect.size.width != 1.0 || cropRect.size.height != 1.0 {
                updatePreviewImageWithoutCropWithCompletion {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                    self.reCalculateCropRectBounds()
                    self.setCropRectForSelectionRatio()
                    self.cropRectComponent.present()
                }
        } else {
            reCalculateCropRectBounds()
            setCropRectForSelectionRatio()
            cropRectComponent.present()
        }

        scrollView.flashScrollIndicators()
    }

    // MARK: - EditorViewController

    public override var options: CropEditorViewControllerOptions {
        return self.configuration.cropEditorViewControllerOptions
    }

    override var enableZoomingInPreviewImage: Bool {
        return false
    }

    public override func zoomingImageViewDidZoom(zoomingImageView: ZoomingImageView) {
        super.zoomingImageViewDidZoom(zoomingImageView)

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

    private func configureScrollView() {
        bottomContainerView.addSubview(scrollView)

        let views = [ "scrollView" : scrollView ]
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scrollView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: views))
    }

    private func configureButtons() {
        for cropRatio in options.allowedCropRatios {
            let button = ImageCaptionButton()
            button.textLabel.text = cropRatio.title
            button.accessibilityLabel = cropRatio.accessibilityLabel
            button.imageView.image = cropRatio.icon
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: "activateRatio:", forControlEvents: .TouchUpInside)
            options.actionButtonConfigurationClosure?(button, cropRatio)
            cropRatioToButton[cropRatio] = button
        }

        var views = [String: UIView]()
        var viewNames = [String]()
        for cropRatio in options.allowedCropRatios {
            let button = cropRatioToButton[cropRatio]!
            let viewName = "_\(String(abs(button.hash)))" // View names must start with a letter or underscore
            viewNames.append(viewName)
            scrollView.addSubview(button)
            views[viewName] = button
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)(==100)]|", options: [], metrics: nil, views: views))
        }

        // Button Constraints
        let visualFormatString = viewNames.reduce("") { (acc, name) -> String in
            return acc + "[\(name)(==buttonWidth)]"
        }

        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 70 ], views: views))

        // Select first button
        if let firstCropAction = options.allowedCropRatios.first {
            selectedButton = cropRatioToButton[firstCropAction]
        }
    }

    private func configureCropRect() {
        view.addSubview(transparentRectView)
        cropRectComponent.cropRect = fixedFilterStack.orientationCropFilter.cropRect
        cropRectComponent.setup(transparentRectView, parentView: self.view, showAnchors: true)
        addGestureRecognizerToTransparentView()
        addGestureRecognizerToAnchors()
    }

    // MARK: - Helpers

    private func updatePreviewImageWithoutCropWithCompletion(completionHandler: PreviewImageGenerationCompletionBlock?) {
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
        addGestureRecognizerToAnchor(cropRectComponent.topLeftAnchor!)
        addGestureRecognizerToAnchor(cropRectComponent.topRightAnchor!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomRightAnchor!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomLeftAnchor!)
    }

    private func addGestureRecognizerToAnchor(anchor: UIImageView) {
        anchor.userInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        anchor.addGestureRecognizer(panGestureRecognizer)
    }

    public func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.view!.isEqual(cropRectComponent.topRightAnchor) {
            handlePanOnTopRight(recognizer)
        } else if recognizer.view!.isEqual(cropRectComponent.topLeftAnchor) {
            handlePanOnTopLeft(recognizer)
        } else if recognizer.view!.isEqual(cropRectComponent.bottomLeftAnchor) {
            handlePanOnBottomLeft(recognizer)
        } else if recognizer.view!.isEqual(cropRectComponent.bottomRightAnchor) {
            handlePanOnBottomRight(recognizer)
        } else if recognizer.view!.isEqual(transparentRectView) {
            handlePanOnTransparentView(recognizer)
        }

        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
    }

    public func handlePanOnTopLeft(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.bottomRightAnchor!.center.x - location.x
        var sizeY = cropRectComponent.bottomRightAnchor!.center.y - location.y

        sizeX = CGFloat(Int(sizeX))
        sizeY = CGFloat(Int(sizeY))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForTopLeftAnchor(size)
        var center = cropRectComponent.topLeftAnchor!.center
        center.x += (cropRectComponent.cropRect.size.width - size.width)
        center.y += (cropRectComponent.cropRect.size.height - size.height)
        cropRectComponent.topLeftAnchor!.center = center
        recalculateCropRectFromTopLeftAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForTopLeftAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)

            if (cropRectComponent.bottomRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.bottomRightAnchor!.center.x - cropRectLeftBound
                newSize.height = newSize.width / CGFloat(selectionRatio)
            }
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.bottomRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.bottomRightAnchor!.center.x - cropRectLeftBound
            }
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
            }
        }
        return newSize
    }

    private func recalculateCropRectFromTopLeftAnchor() {
        cropRectComponent.cropRect = CGRect(x: cropRectComponent.topLeftAnchor!.center.x,
            y: cropRectComponent.topLeftAnchor!.center.y,
            width: cropRectComponent.bottomRightAnchor!.center.x - cropRectComponent.topLeftAnchor!.center.x,
            height: cropRectComponent.bottomRightAnchor!.center.y - cropRectComponent.topLeftAnchor!.center.y)
    }

    private func handlePanOnTopRight(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.bottomLeftAnchor!.center.x - location.x
        var sizeY = cropRectComponent.bottomLeftAnchor!.center.y - location.y

        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForTopRightAnchor(size)
        var center = cropRectComponent.topRightAnchor!.center
        center.x = (cropRectComponent.bottomLeftAnchor!.center.x + size.width)
        center.y = (cropRectComponent.bottomLeftAnchor!.center.y - size.height)
        cropRectComponent.topRightAnchor!.center = center
        recalculateCropRectFromTopRightAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForTopRightAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height = cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            if (cropRectComponent.bottomRightAnchor!.center.y - newSize.height) < cropRectTopBound {
                newSize.height =  cropRectComponent.bottomRightAnchor!.center.y - cropRectTopBound
            }
        }
        return newSize
    }

    private func recalculateCropRectFromTopRightAnchor() {
        cropRectComponent.cropRect = CGRect(x: cropRectComponent.bottomLeftAnchor!.center.x,
            y: cropRectComponent.topRightAnchor!.center.y,
            width: cropRectComponent.topRightAnchor!.center.x - cropRectComponent.bottomLeftAnchor!.center.x,
            height: cropRectComponent.bottomLeftAnchor!.center.y - cropRectComponent.topRightAnchor!.center.y)
    }


    private func handlePanOnBottomLeft(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.topRightAnchor!.center.x - location.x
        var sizeY = cropRectComponent.topRightAnchor!.center.y - location.y

        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForBottomLeftAnchor(size)
        var center = cropRectComponent.bottomLeftAnchor!.center
        center.x = (cropRectComponent.topRightAnchor!.center.x - size.width)
        center.y = (cropRectComponent.topRightAnchor!.center.y + size.height)
        cropRectComponent.bottomLeftAnchor!.center = center
        recalculateCropRectFromTopRightAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForBottomLeftAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)

            if (cropRectComponent.topRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.topRightAnchor!.center.x - cropRectLeftBound
                newSize.height = newSize.width / CGFloat(selectionRatio)
            }

            if (cropRectComponent.topRightAnchor!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topRightAnchor!.center.y
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.topRightAnchor!.center.x - newSize.width) < cropRectLeftBound {
                newSize.width = cropRectComponent.topRightAnchor!.center.x - cropRectLeftBound
            }
            if (cropRectComponent.topRightAnchor!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topRightAnchor!.center.y
            }
        }
        return newSize
    }

    private func handlePanOnBottomRight(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        var sizeX = cropRectComponent.topLeftAnchor!.center.x - location.x
        var sizeY = cropRectComponent.topLeftAnchor!.center.y - location.y
        sizeX = CGFloat(abs(Int(sizeX)))
        sizeY = CGFloat(abs(Int(sizeY)))
        var size = CGSize(width: sizeX, height: sizeY)
        size = applyMinimumAreaRuleToSize(size)
        size = reCalulateSizeForBottomRightAnchor(size)
        var center = cropRectComponent.bottomRightAnchor!.center
        center.x -= (cropRectComponent.cropRect.size.width - size.width)
        center.y -= (cropRectComponent.cropRect.size.height - size.height)
        cropRectComponent.bottomRightAnchor!.center = center
        recalculateCropRectFromTopLeftAnchor()
        cropRectComponent.layoutViewsForCropRect()
    }

    private func reCalulateSizeForBottomRightAnchor(size: CGSize) -> CGSize {
        var newSize = size
        if let selectionRatio = selectionMode?.ratio {
            newSize.height = newSize.height * CGFloat(selectionRatio)
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            newSize.height = newSize.width / CGFloat(selectionRatio)
            if (cropRectComponent.topLeftAnchor!.center.y + newSize.height) > cropRectBottomBound {
                newSize.height = cropRectBottomBound - cropRectComponent.topLeftAnchor!.center.y
                newSize.width = newSize.height * CGFloat(selectionRatio)
            }
        } else {
            if (cropRectComponent.topLeftAnchor!.center.x + newSize.width) > cropRectRightBound {
                newSize.width = cropRectRightBound - cropRectComponent.topLeftAnchor!.center.x
            }
            if (cropRectComponent.topLeftAnchor!.center.y + newSize.height) >  cropRectBottomBound {
                newSize.height =  cropRectBottomBound - cropRectComponent.topLeftAnchor!.center.y
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

    private func calculateDragOffsetOnNewDrag(recognizer recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(transparentRectView)
        if recognizer.state == UIGestureRecognizerState.Began {
            dragOffset = CGPoint(x: location.x - cropRectComponent.cropRect.origin.x, y: location.y - cropRectComponent.cropRect.origin.y)
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
        return CGPoint(x: locationX, y: locationY)
    }

    private func normalizedCropRect() -> CGRect {
        reCalculateCropRectBounds()
        let boundWidth = cropRectRightBound - cropRectLeftBound
        let boundHeight = cropRectBottomBound - cropRectTopBound
        let x = (cropRectComponent.cropRect.origin.x - cropRectLeftBound) / boundWidth
        let y = (cropRectComponent.cropRect.origin.y - cropRectTopBound) / boundHeight
        return CGRect(x: x, y: y, width: cropRectComponent.cropRect.size.width / boundWidth, height: cropRectComponent.cropRect.size.height / boundHeight)
    }

    private func reCalculateCropRectBounds() {
        let width = transparentRectView.frame.size.width
        let height = transparentRectView.frame.size.height
        cropRectLeftBound = (width - previewImageView.visibleImageFrame.size.width) / 2.0
        cropRectRightBound = width - cropRectLeftBound
        cropRectTopBound = (height - previewImageView.visibleImageFrame.size.height) / 2.0
        cropRectBottomBound = height - cropRectTopBound
    }

    private func applyMinimumAreaRuleToSize(size: CGSize) -> CGSize {
        var newSize = size
        if newSize.width < kMinimumCropSize {
            newSize.width = kMinimumCropSize
        }

        if newSize.height < kMinimumCropSize {
            newSize.height = kMinimumCropSize
        }

        return newSize
    }

    private func setCropRectForSelectionRatio() {
        let size = CGSize(width: cropRectRightBound - cropRectLeftBound,
            height: cropRectBottomBound - cropRectTopBound)
        var rectWidth = size.width
        var rectHeight = rectWidth

        if size.width > size.height {
            rectHeight = size.height
            rectWidth = rectHeight
        }

        let selectionRatio = selectionMode?.ratio ?? 1

        if selectionRatio >= 1 {
            rectHeight /= CGFloat(selectionRatio)
        } else {
            rectWidth *= CGFloat(selectionRatio)
        }

        let sizeDeltaX = (size.width - rectWidth) / 2.0
        let sizeDeltaY = (size.height - rectHeight) / 2.0

        cropRectComponent.cropRect = CGRect(
            x: cropRectLeftBound  + sizeDeltaX,
            y: cropRectTopBound + sizeDeltaY,
            width: rectWidth,
            height: rectHeight)
    }

    private func updateCropRectForSelectionMode() {
        if let _ = selectionMode?.ratio {
            setCropRectForSelectionRatio()
            cropRectComponent.layoutViewsForCropRect()
        }
    }

    // MARK: - Actions

    @objc private func activateRatio(sender: ImageCaptionButton) {
        if selectedButton == sender {
            return
        }

        if let cropRatio = ((cropRatioToButton as NSDictionary).allKeysForObject(sender) as? [CropRatio])?.first {
            selectionMode = cropRatio
            updateCropRectForSelectionMode()
            selectedButton = sender
        }
    }
}
