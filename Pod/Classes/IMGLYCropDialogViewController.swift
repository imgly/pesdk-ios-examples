//
//  IMGLYCropDialogViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 15/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYSelectionMode: Int {
    case Free,
    OneToOne,
    FourToThree,
    SixteenToNine
}


public class IMGLYCropDialogViewController: UIViewController, UIGestureRecognizerDelegate,
IMGLYSubEditorViewControllerProtocol, IMGLYCropDialogViewDelegate {

    public let kMinimumCropSize:CGFloat = 50.0

    private var dragOffset_:CGPoint = CGPointZero
    private var cropRectLeftBound_:CGFloat = 0.0
    private var cropRectRightBound_:CGFloat = 0.0
    private var cropRectTopBound_:CGFloat = 0.0
    private var cropRectBottomBound_:CGFloat = 0.0
    public var selectionMode_:IMGLYSelectionMode = IMGLYSelectionMode.Free
    public var selectionRatio_:CGFloat = 1.0

    private var previewImage_:UIImage?
    public var previewImage:UIImage? {
        get {
            return previewImage_
        }
        set (image) {
            previewImage_ = image
        }
    }
    
    private var completionHandler_:IMGLYSubEditorCompletionBlock?
    public var completionHandler:IMGLYSubEditorCompletionBlock? {
        get {
            return completionHandler_
        }
        set (handler) {
            completionHandler_ = handler
        }
    }
    
    private var fixedFilterStack_:FixedFilterStack?
    public var fixedFilterStack:FixedFilterStack? {
        get {
            return fixedFilterStack_
        }
        set (filterStack){
            fixedFilterStack_ = filterStack
        }
    }
    
    public var dialogView:UIView? {
        get {
            return view
        }
        set(newView) {
            view = newView
        }
    }

    private var dialogView_:IMGLYCropDialogView?
    private var oldRect_ = CGRectZero
    private var filteredImage_:UIImage?
    private let cropRectComponent = IMGLYInstanceFactory.sharedInstance.cropRectComponent()

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        self.view = IMGLYCropDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        oldRect_ = fixedFilterStack!.orientationCropFilter.cropRect
        fixedFilterStack!.orientationCropFilter.cropRect = CGRectMake(0, 0, 1, 1)
        dialogView_ = self.view as? IMGLYCropDialogView
        dialogView_?.delegate = self
        cropRectComponent.setup(dialogView_!.transperentRectView, parentView: self.view, showAnchors: true)
        addGestureRecognizerToTransparentView()
        addGestureRecognizerToAnchors()
    }
    
    public override func viewDidAppear(animated: Bool) {
        updatePreviewImage()
        reCalculateCropRectBounds()
        setInitialCropRect()
        cropRectComponent.present()
    }
    
    // MARK:- setup
    
    // MARK:- gestures setup
    private func addGestureRecognizerToTransparentView() {
        self.dialogView_?.transperentRectView.userInteractionEnabled = true
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.delegate = self
        self.dialogView_?.transperentRectView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addGestureRecognizerToAnchors() {
        addGestureRecognizerToAnchor(cropRectComponent.topLeftAnchor_!)
        addGestureRecognizerToAnchor(cropRectComponent.topRightAnchor_!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomRightAnchor_!)
        addGestureRecognizerToAnchor(cropRectComponent.bottomLeftAnchor_!)
    }
    
    private func addGestureRecognizerToAnchor(anchor:UIImageView) {
        anchor.userInteractionEnabled = true
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.delegate = self
        anchor.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK:- gesture handling
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
        else if recognizer.view!.isEqual(self.dialogView_!.transperentRectView) {
            handlePanOnTransparentView(recognizer)
        }
    }
    
    // MARK: top left
    public func handlePanOnTopLeft(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(dialogView_!.transperentRectView)
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
        if selectionMode_ != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio_
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / selectionRatio_
            
            if (cropRectComponent.bottomRightAnchor_!.center.x - newSize.width) < cropRectLeftBound_ {
                newSize.width = cropRectComponent.bottomRightAnchor_!.center.x - cropRectLeftBound_
                newSize.height = newSize.width / selectionRatio_
            }
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound_ {
                newSize.height = cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound_
                newSize.width = newSize.height * selectionRatio_
            }
        }
        else {
            if (cropRectComponent.bottomRightAnchor_!.center.x - newSize.width) < cropRectLeftBound_ {
                newSize.width = cropRectComponent.bottomRightAnchor_!.center.x - cropRectLeftBound_
            }
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound_ {
                newSize.height = cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound_
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
    
    // MARK: top right
    private func handlePanOnTopRight(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(dialogView_!.transperentRectView)
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
        if selectionMode_ != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio_
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound_ {
                newSize.width = cropRectRightBound_ - cropRectComponent.topLeftAnchor_!.center.x
            }
            newSize.height = newSize.width / selectionRatio_
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound_ {
                newSize.height = cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound_
                newSize.width = newSize.height * selectionRatio_
            }
        }
        else {
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound_ {
                newSize.width = cropRectRightBound_ - cropRectComponent.topLeftAnchor_!.center.x;
            }
            if (cropRectComponent.bottomRightAnchor_!.center.y - newSize.height) < cropRectTopBound_ {
                newSize.height =  cropRectComponent.bottomRightAnchor_!.center.y - cropRectTopBound_
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
    
    
    // MARK: bottom left
    private func handlePanOnBottomLeft(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(dialogView_!.transperentRectView)
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
        if selectionMode_ != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio_
            if (newSize.height > newSize.width) {
                newSize.width = newSize.height
            }
            newSize.height = newSize.width / selectionRatio_
            
            if (cropRectComponent.topRightAnchor_!.center.x - newSize.width) < cropRectLeftBound_ {
                newSize.width = cropRectComponent.topRightAnchor_!.center.x - cropRectLeftBound_
                newSize.height = newSize.width / selectionRatio_
            }
            
            if (cropRectComponent.topRightAnchor_!.center.y + newSize.height) > cropRectBottomBound_ {
                newSize.height = cropRectBottomBound_ - cropRectComponent.topRightAnchor_!.center.y
                newSize.width = newSize.height * selectionRatio_
            }
        }
        else {
            if (cropRectComponent.topRightAnchor_!.center.x - newSize.width) < cropRectLeftBound_ {
                newSize.width = cropRectComponent.topRightAnchor_!.center.x - cropRectLeftBound_
            }
            if (cropRectComponent.topRightAnchor_!.center.y + newSize.height) > cropRectBottomBound_ {
                newSize.height = cropRectBottomBound_ - cropRectComponent.topRightAnchor_!.center.y
            }
        }
        return newSize
    }
    
    // MARK: bottom right
    private func handlePanOnBottomRight(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(dialogView_!.transperentRectView)
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
        if selectionMode_ != IMGLYSelectionMode.Free {
            newSize.height = newSize.height * selectionRatio_
            if newSize.height > newSize.width {
                newSize.width = newSize.height
            }
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound_ {
                newSize.width = cropRectRightBound_ - cropRectComponent.topLeftAnchor_!.center.x;
            }
            newSize.height = newSize.width / selectionRatio_
            if (cropRectComponent.topLeftAnchor_!.center.y + newSize.height) > cropRectBottomBound_ {
                newSize.height = cropRectBottomBound_ - cropRectComponent.topLeftAnchor_!.center.y
                newSize.width = newSize.height * selectionRatio_
            }
        }
        else {
            if (cropRectComponent.topLeftAnchor_!.center.x + newSize.width) > cropRectRightBound_ {
                newSize.width = cropRectRightBound_ - cropRectComponent.topLeftAnchor_!.center.x
            }
            if (cropRectComponent.topLeftAnchor_!.center.y + newSize.height) >  cropRectBottomBound_ {
                newSize.height =  cropRectBottomBound_ - cropRectComponent.topLeftAnchor_!.center.y
            }
        }
        return newSize
    }
    
    // MARK: rect itself
    private func handlePanOnTransparentView(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(self.dialogView_!.transperentRectView)
        if isPointInRect(cropRectComponent.cropRect, point: location) {
            calculateDragOffsetOnNewDrag(recognizer:recognizer)
            var newLocation = clampedLocationToBounds(location)
            var rect = cropRectComponent.cropRect
            rect.origin.x = newLocation.x - dragOffset_.x
            rect.origin.y = newLocation.y - dragOffset_.y
            cropRectComponent.cropRect = rect
            cropRectComponent.layoutViewsForCropRect()
        }
    }
    
    private func calculateDragOffsetOnNewDrag(#recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(self.dialogView_?.transperentRectView)
        if recognizer.state == UIGestureRecognizerState.Began {
            dragOffset_ = CGPointMake(location.x - cropRectComponent.cropRect.origin.x, location.y - cropRectComponent.cropRect.origin.y)
        }
    }
    
    private func clampedLocationToBounds(location:CGPoint) -> CGPoint {
        var rect = cropRectComponent.cropRect
        var locationX = location.x
        var locationY = location.y
        var left = locationX - dragOffset_.x
        var right = left + rect.size.width
        var top  = locationY - dragOffset_.y
        var bottom = top + rect.size.height
        
        if left < cropRectLeftBound_ {
            locationX = cropRectLeftBound_ + dragOffset_.x
        }
        if right > cropRectRightBound_ {
            locationX = cropRectRightBound_ - cropRectComponent.cropRect.size.width  + dragOffset_.x
        }
        if top < cropRectTopBound_ {
            locationY = cropRectTopBound_ + dragOffset_.y
        }
        if bottom > cropRectBottomBound_ {
            locationY = cropRectBottomBound_ - cropRectComponent.cropRect.size.height + dragOffset_.y
        }
        return CGPointMake(locationX, locationY)
    }
    
    
    // MARK:- helpers
    private func isPointInRect(rect:CGRect, point:CGPoint) -> Bool {
        var top = rect.origin.y
        var bottom = top + rect.size.height
        var left = rect.origin.x
        var right = left + rect.size.width
        var inRectXAxis = point.x > left && point.x < right
        var inRectYAxis = point.y > top && point.y < bottom
        return (inRectXAxis && inRectYAxis)
    }
    
    private func normalizedCropRect() -> CGRect {
        reCalculateCropRectBounds()
        var boundWidth = cropRectRightBound_ - cropRectLeftBound_
        var boundHeight = cropRectBottomBound_ - cropRectTopBound_
        var x = (cropRectComponent.cropRect.origin.x - cropRectLeftBound_) / boundWidth
        var y = (cropRectComponent.cropRect.origin.y - cropRectTopBound_) / boundHeight
        return CGRectMake(x, y, cropRectComponent.cropRect.size.width / boundWidth, cropRectComponent.cropRect.size.height / boundHeight)
    }
    
    private func reCalculateCropRectBounds() {
        var size = scaledImageSize()
        var width = dialogView_!.transperentRectView.frame.size.width
        var height = dialogView_!.transperentRectView.frame.size.height
        cropRectLeftBound_ = (width - size.width) / 2.0
        cropRectRightBound_ = width - cropRectLeftBound_
        cropRectTopBound_ = (height - size.height) / 2.0
        cropRectBottomBound_ = height - cropRectTopBound_
    }
    
    private func scaledImageSize() -> CGSize {
        var widthRatio = dialogView_!.previewImageView.bounds.size.width / dialogView_!.previewImageView.image!.size.width
        var heightRatio = dialogView_!.previewImageView.bounds.size.height / dialogView_!.previewImageView.image!.size.height
        var scale = min(widthRatio, heightRatio)
        var size = CGSizeZero
        size.width = scale * dialogView_!.previewImageView.image!.size.width
        size.height = scale * dialogView_!.previewImageView.image!.size.height
        return size
    }
    
    private func applyMinimumAreaRuleToSize(size:CGSize) -> CGSize {
        var newSize = size
        if newSize.width < kMinimumCropSize {
            newSize.width = kMinimumCropSize
        }
        
        if newSize.height < kMinimumCropSize {
            newSize.height = kMinimumCropSize
        }
        return newSize
    }
    
    // MARK:- IMGLYCropDialogViewDelegate
    public func doneButtonPressed() {
        if self.completionHandler != nil {
            var rect = normalizedCropRect()
            fixedFilterStack!.orientationCropFilter.cropRect = rect
            filteredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
            self.completionHandler?(IMGLYEditorResult.Done, filteredImage_)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        if self.completionHandler != nil {
            fixedFilterStack!.orientationCropFilter.cropRect  = oldRect_
            self.completionHandler?(IMGLYEditorResult.Cancel, nil)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    
    // Mark:- Ratio related
    public func ratio1to1ButtonPressed() {
        selectionMode_ = IMGLYSelectionMode.OneToOne
        calculateRatioForSelectionMode()
    }
    
    public func ratio4to3ButtonPressed() {
        selectionMode_ = IMGLYSelectionMode.FourToThree
        calculateRatioForSelectionMode()
    }
    
    public func ratio16to9ButtonPressed() {
        selectionMode_ = IMGLYSelectionMode.SixteenToNine
        calculateRatioForSelectionMode()
    }
    
    public func ratioFreeButtonPressed() {
        selectionMode_ = IMGLYSelectionMode.Free
        calculateRatioForSelectionMode()
    }
    
    private func calculateRatioForSelectionMode() {
        if selectionMode_ == IMGLYSelectionMode.FourToThree {
            selectionRatio_ = 4.0 / 3.0
        }
        else if selectionMode_ == IMGLYSelectionMode.OneToOne {
            selectionRatio_ = 1.0
        }
        else if selectionMode_ == IMGLYSelectionMode.SixteenToNine {
            selectionRatio_ = 16.0 / 9.0
        }
        if selectionMode_ != IMGLYSelectionMode.Free {
            setCropRectForSelectionRatio()
            cropRectComponent.layoutViewsForCropRect()
        }
    }
    
    // MARK:- update
    public func updatePreviewImage() {
        filteredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
        dialogView_!.previewImageView.image = filteredImage_
    }
    
    private func setInitialCropRect() {
        selectionRatio_ = 1.0
        setCropRectForSelectionRatio()
    }
    
    private func setCropRectForSelectionRatio() {
        var size = CGSizeMake(cropRectRightBound_ - cropRectLeftBound_,
            cropRectBottomBound_ - cropRectTopBound_)
        var rectWidth = size.width
        var rectHeight = rectWidth
        if size.width > size.height {
            rectHeight = size.height
            rectWidth = rectHeight
        }
        rectHeight /= selectionRatio_
        
        let sizeDeltaX = (size.width - rectWidth) / 2.0
        let sizeDeltaY = (size.height - rectHeight) / 2.0
        
        cropRectComponent.cropRect = CGRectMake(
            cropRectLeftBound_  + sizeDeltaX,
            cropRectTopBound_ + sizeDeltaY,
            rectWidth,
            rectHeight)
        fixedFilterStack!.orientationCropFilter.cropRect = normalizedCropRect()
    }
}
