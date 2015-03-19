//
//  CameraView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 30/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

@objc public protocol IMGLYCameraViewDelegate {
    func takePhotoButtonPressed()
    func toggleFilterButtonPressed()
    func selectFromRollButtonPressed()
    func toggleCameraButtonPressed()
    func flashModeButtonPressed()
}

public class IMGLYCameraView: UIView {
    // MARK: - IMGYCameraView protocol
    @IBOutlet public weak var streamPreview_: UIView!
    @IBOutlet public weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet public weak var filterSelectorView_: IMGLYFilterSelectorView!
    @IBOutlet public weak var selectFromCameraRollButton: UIButton!
    @IBOutlet public weak var flashModeButton: UIButton!
    @IBOutlet public weak var toggleCameraButton: UIButton!
    @IBOutlet public weak var takePhotoButton: UIButton!
    @IBOutlet public weak var toggleFilterLabel: UILabel!
    @IBOutlet public weak var toggleFilterSelectorButton: UIButton!
    
    private var autoFlashSupported_ = true
    private weak var delegate_:IMGLYCameraViewDelegate?
    public var filterSelectorHidden:Bool = true
    public weak var delegate:IMGLYCameraViewDelegate? {
        get {
            return delegate_
        }
        set(delegate) {
            delegate_ = delegate
        }
    }
    
    public var streamPreview:UIView {
        get {
            return streamPreview_;
        }
    }

    public var filterSelectorView:IMGLYFilterSelectorView {
        get {
            return filterSelectorView_;
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - View connection
    @IBOutlet public var contentView: UIView!
    
    public func setup() {
        var containerViewHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        containerViewHelper.loadXib("IMGLYCameraView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
        //setLastImageFromRollAsPreview()
        setupTakePhotoButton()
    }
    
    public func setupTakePhotoButton () {
        takePhotoButton.imageView?.animationImages = [UIImage]()
        takePhotoButton.imageView?.animationRepeatCount = 1
        takePhotoButton.adjustsImageWhenHighlighted = false

        for var index = 0; index < 10; index++ {
            let image = String(format: "LensAperture_ShapeLayer_%05d", index)
            takePhotoButton.imageView?.animationImages?.append(UIImage(named: image, inBundle: NSBundle(forClass: IMGLYCameraView.self), compatibleWithTraitCollection:nil)!)
        }
    }
    
    // MARK: - Button handling
    @IBAction public func takePhotoButtonPressed(sender: AnyObject) {
        takePhotoButton.imageView?.startAnimating()
        
        if self.delegate != nil{
            self.delegate!.takePhotoButtonPressed()
        }
    }
    
    @IBAction public func toggleFilterSelectorButtonPressed(sender: AnyObject) {
        self.bottomSpaceConstraint.constant = self.filterSelectorHidden ? 100 : 0;
        self.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(Double(0.2), animations: {
            self.layoutIfNeeded()
            },
            completion: { finished in
                if(finished) {
                    self.filterSelectorHidden = !self.filterSelectorHidden
                }
            }
        )
        
        if let delegate = self.delegate {
            delegate.toggleFilterButtonPressed()
        }
    }
    
    @IBAction public func selectImageFromCameraRollButtonPressed(sender: AnyObject) {
        delegate?.selectFromRollButtonPressed()
    }
    
    @IBAction public func toggleCameraButtonPressed(sender: AnyObject) {
        delegate?.toggleCameraButtonPressed()
    }

    @IBAction public func flashModeButtonPressed(sender: AnyObject) {
        delegate?.flashModeButtonPressed()
    }

    public func setLastImageFromRollAsPreview() {
        if UIDevice().systemVersion.hasPrefix("7") {
            setLatestImageFromRollAsPreviewForIOS7()
        } else {
            setLatestImageFromRollAsPreviewForIOS8()
        }
    }
    
    private func setLatestImageFromRollAsPreviewForIOS8() {
        var fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        if (fetchResult.lastObject != nil) {
            var lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: CGSizeMake(100, 100), contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.selectFromCameraRollButton!.setImage(result, forState: UIControlState.Normal)
            }
        }
    }
    
    private func setLatestImageFromRollAsPreviewForIOS7() {
        var assetLib = ALAssetsLibrary()
        var url: NSURL = NSURL()
        assetLib.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos), usingBlock: { (group:ALAssetsGroup!, var stopEnumeration) -> Void in
            if group != nil {
                group!.setAssetsFilter(ALAssetsFilter.allPhotos())
                
                group!.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: { (asset:ALAsset?, index, var innerStopEnumeration) -> Void in
                    innerStopEnumeration.memory =  ObjCBool(true)
                    stopEnumeration.memory =  ObjCBool(true)
                    let cgImage = asset?.thumbnail().takeUnretainedValue()
                    
                    if let image = UIImage(CGImage: cgImage) {
                        self.selectFromCameraRollButton!.setImage(image, forState: UIControlState.Normal)
                    }
                })
            }
            }) { (error:NSError!) -> Void in
        }
    }
    
    public func enableButtons() {
        setButtonsEnabledStateTo(true)
    }
    
    public func disableButtons() {
        setButtonsEnabledStateTo(false)
    }

    private func setButtonsEnabledStateTo(state:Bool) {
        toggleCameraButton.enabled = state
        flashModeButton.enabled = state
        takePhotoButton.enabled = state
        selectFromCameraRollButton.enabled = state
        filterSelectorView_.userInteractionEnabled = state
        toggleFilterSelectorButton.enabled = state
        //toggleCameraButton.hidden = !state
        //flashModeButton.hidden = !state
    }
    
    public func setFlashMode(flashMode:AVCaptureFlashMode) {
        switch(flashMode) {
        case AVCaptureFlashMode.Auto:
            self.flashModeButton.setImage(UIImage(named: "flash_auto", inBundle: NSBundle(forClass: IMGLYCameraView.self), compatibleWithTraitCollection:nil), forState: UIControlState.Normal)
        case AVCaptureFlashMode.On:
            self.flashModeButton.setImage(UIImage(named: "flash_on", inBundle: NSBundle(forClass: IMGLYCameraView.self), compatibleWithTraitCollection:nil), forState: UIControlState.Normal)
        case AVCaptureFlashMode.Off:
            self.flashModeButton.setImage(UIImage(named: "flash_off", inBundle: NSBundle(forClass: IMGLYCameraView.self), compatibleWithTraitCollection:nil), forState: UIControlState.Normal)
        }
    }
}
