//
//  IMGLYCameraViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

let InitialFilterIntensity = Float(0.75)
private let ShowFilterIntensitySliderInterval = NSTimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)
public typealias IMGLYCameraCompletionBlock = (UIImage?) -> (Void)

enum RecordingMode {
    case Photo
    case Video
}

public class IMGLYCameraViewController: UIViewController {
    
    // MARK: - Properties
    
    public private(set) lazy var topControlsView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    public private(set) lazy var cameraPreviewContainer: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.clipsToBounds = true
        return view
        }()
    
    public private(set) lazy var bottomControlsView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    public private(set) lazy var flashButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.contentHorizontalAlignment = .Left
        button.addTarget(self, action: "changeFlash:", forControlEvents: .TouchUpInside)
        button.hidden = true
        return button
        }()
    
    public private(set) lazy var switchCameraButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "cam_switch", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.contentHorizontalAlignment = .Right
        button.addTarget(self, action: "switchCamera:", forControlEvents: .TouchUpInside)
        button.hidden = true
        return button
        }()
    
    public private(set) lazy var cameraRollButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "nonePreview", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.imageView?.contentMode = .ScaleAspectFill
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "showCameraRoll:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var takePhotoButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "LensAperture_ShapeLayer_00000", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.imageView?.animationImages = [UIImage]()
        button.imageView?.animationRepeatCount = 1
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: "takePhoto:", forControlEvents: .TouchUpInside)
        
        for var index = 0; index < 10; index++ {
            let image = String(format: "LensAperture_ShapeLayer_%05d", index)
            button.imageView?.animationImages?.append(UIImage(named: image, inBundle: bundle, compatibleWithTraitCollection:nil)!)
        }
        
        return button
        }()
    
    public private(set) lazy var recordVideoButton: IMGLYVideoRecordButton = {
        let button = IMGLYVideoRecordButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "recordVideo:", forControlEvents: .TouchUpInside)
        button.hidden = true
        button.alpha = 0
        return button
        }()
    
    public private(set) lazy var filterSelectionButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "show_filter", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "toggleFilters:", forControlEvents: .TouchUpInside)
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        return button
        }()
    
    public private(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let slider = UISlider()
        slider.setTranslatesAutoresizingMaskIntoConstraints(false)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.75
        slider.alpha = 0
        slider.addTarget(self, action: "changeIntensity:", forControlEvents: .ValueChanged)
        
        slider.minimumTrackTintColor = UIColor.whiteColor()
        slider.maximumTrackTintColor = UIColor.whiteColor()
        slider.thumbTintColor = UIColor(red:1, green:0.8, blue:0, alpha:1)
        let sliderThumbImage = UIImage(named: "slider_thumb_image", inBundle: bundle, compatibleWithTraitCollection: nil)
        slider.setThumbImage(sliderThumbImage, forState: .Normal)
        slider.setThumbImage(sliderThumbImage, forState: .Highlighted)
        
        return slider
    }()
    
    public private(set) lazy var photoModeButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(NSLocalizedString("camera-view-controller.mode.photo", tableName: nil, bundle: bundle, value: "", comment: ""), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor(red:1, green:0.8, blue:0, alpha:1), forState: .Selected)
        button.addTarget(self, action: "toggleMode:", forControlEvents: .TouchUpInside)
        button.selected = true
        button.userInteractionEnabled = false
        return button
    }()
    
    public private(set) lazy var videoModeButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(NSLocalizedString("camera-view-controller.mode.video", tableName: nil, bundle: bundle, value: "", comment: ""), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor(red:1, green:0.8, blue:0, alpha:1), forState: .Selected)
        button.addTarget(self, action: "toggleMode:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    public private(set) lazy var swipeRightGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: "toggleMode:")
        return recognizer
    }()
    
    public private(set) lazy var swipeLeftGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: "toggleMode:")
        recognizer.direction = .Left
        return recognizer
    }()
    
    /// If set to false, no video controls are shown.
    /// This attribute has to be set before the view is loaded.
    public var videoEnabled = true
    
    private var recordingMode = RecordingMode.Photo {
        didSet {
            if recordingMode == oldValue {
                return
            }
            
            if let centerModeButtonConstraint = centerModeButtonConstraint {
                bottomControlsView.removeConstraint(centerModeButtonConstraint)
            }
            
            let target: UIButton
            switch recordingMode {
            case .Photo:
                target = photoModeButton
                photoModeButton.userInteractionEnabled = false
                videoModeButton.userInteractionEnabled = true
                takePhotoButton.hidden = false
            case .Video:
                target = videoModeButton
                photoModeButton.userInteractionEnabled = true
                videoModeButton.userInteractionEnabled = false
                recordVideoButton.hidden = false
            }
            
            centerModeButtonConstraint = NSLayoutConstraint(item: target, attribute: .CenterX, relatedBy: .Equal, toItem: takePhotoButton, attribute: .CenterX, multiplier: 1, constant: 0)
            bottomControlsView.addConstraint(centerModeButtonConstraint!)
            
            UIView.animateWithDuration(0.25, animations: {
                target.selected = true
                
                if target == self.photoModeButton {
                    self.takePhotoButton.alpha = 1
                    self.recordVideoButton.alpha = 0
                    self.videoModeButton.selected = false
                } else {
                    self.takePhotoButton.alpha = 0
                    self.recordVideoButton.alpha = 1
                    self.photoModeButton.selected = false
                }
                
                self.bottomControlsView.layoutIfNeeded()
                }) { finished in
                    if target == self.photoModeButton {
                        self.recordVideoButton.hidden = true
                    } else {
                        self.takePhotoButton.hidden = true
                    }
            }
        }
    }
    
    private var hideSliderTimer: NSTimer?
    
    private var filterSelectionViewConstraint: NSLayoutConstraint?
    public let filterSelectionController = IMGLYFilterSelectionController()
    
    public private(set) var cameraController: IMGLYCameraController?
    
    private var buttonsEnabled = true {
        didSet {
            flashButton.enabled = buttonsEnabled
            switchCameraButton.enabled = buttonsEnabled
            cameraRollButton.enabled = buttonsEnabled
            takePhotoButton.enabled = buttonsEnabled
            recordVideoButton.enabled = buttonsEnabled
            videoModeButton.enabled = buttonsEnabled
            photoModeButton.enabled = buttonsEnabled
            swipeRightGestureRecognizer.enabled = buttonsEnabled
            swipeLeftGestureRecognizer.enabled = buttonsEnabled
            filterSelectionController.view.userInteractionEnabled = buttonsEnabled
            filterSelectionButton.enabled = buttonsEnabled
        }
    }
    
    public var completionBlock: IMGLYCameraCompletionBlock?
    
    private var centerModeButtonConstraint: NSLayoutConstraint?
    
    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        configureViewHierarchy()
        configureViewConstraints()
        configureFilterSelectionController()
        configureCameraController()
        
        if videoEnabled {
            view.addGestureRecognizer(swipeLeftGestureRecognizer)
            view.addGestureRecognizer(swipeRightGestureRecognizer)
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.endAppearanceTransition()
        }
        
        setLastImageFromRollAsPreview()
        cameraController?.startCamera()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cameraController?.stopCamera()
        
        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.endAppearanceTransition()
        }
    }
    
    public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }

    // MARK: - Configuration
    
    private func configureViewHierarchy() {
        view.addSubview(topControlsView)
        view.addSubview(cameraPreviewContainer)
        view.addSubview(bottomControlsView)
        
        addChildViewController(filterSelectionController)
        filterSelectionController.didMoveToParentViewController(self)
        view.addSubview(filterSelectionController.view)
        
        topControlsView.addSubview(flashButton)
        topControlsView.addSubview(switchCameraButton)
        
        if videoEnabled {
            bottomControlsView.addSubview(photoModeButton)
            bottomControlsView.addSubview(videoModeButton)
        }
        
        bottomControlsView.addSubview(cameraRollButton)
        bottomControlsView.addSubview(takePhotoButton)
        bottomControlsView.addSubview(recordVideoButton)
        bottomControlsView.addSubview(filterSelectionButton)
        
        cameraPreviewContainer.addSubview(filterIntensitySlider)
    }
    
    private func configureViewConstraints() {
        let views: [NSObject : AnyObject] = [
            "topLayoutGuide" : topLayoutGuide,
            "topControlsView" : topControlsView,
            "cameraPreviewContainer" : cameraPreviewContainer,
            "bottomControlsView" : bottomControlsView,
            "filterSelectionView" : filterSelectionController.view,
            "flashButton" : flashButton,
            "switchCameraButton" : switchCameraButton,
            "cameraRollButton" : cameraRollButton,
            "takePhotoButton" : takePhotoButton,
            "recordVideoButton" : recordVideoButton,
            "filterSelectionButton" : filterSelectionButton,
            "filterIntensitySlider" : filterIntensitySlider,
            "photoModeButton" : photoModeButton,
            "videoModeButton" : videoModeButton
        ]
        
        let metrics: [NSObject : NSNumber] = [
            "topControlsViewHeight" : 44,
            "filterSelectionViewHeight" : FilterSelectionViewHeight,
            "topControlMargin" : 20,
            "topControlMinWidth" : 44,
            "filterIntensitySliderLeftRightMargin" : 10
        ]
        
        configureSuperviewConstraintsWithMetrics(metrics, views: views)
        configureTopControlsConstraintsWithMetrics(metrics, views: views)
        configureCameraPreviewContainerConstraintsWithMetrics(metrics, views: views)
        configureBottomControlsConstraintsWithMetrics(metrics, views: views)
    }
    
    private func configureSuperviewConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[topControlsView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[cameraPreviewContainer]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomControlsView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: nil, metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][topControlsView(==topControlsViewHeight)][cameraPreviewContainer][bottomControlsView][filterSelectionView(==filterSelectionViewHeight)]", options: nil, metrics: metrics, views: views))
        
        filterSelectionViewConstraint = NSLayoutConstraint(item: filterSelectionController.view, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(filterSelectionViewConstraint!)
    }
    
    private func configureTopControlsConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==topControlMargin)-[flashButton(>=topControlMinWidth)]-(>=topControlMargin)-[switchCameraButton(>=topControlMinWidth)]-(==topControlMargin)-|", options: nil, metrics: metrics, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flashButton]|", options: nil, metrics: nil, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[switchCameraButton]|", options: nil, metrics: nil, views: views))
    }
    
    private func configureCameraPreviewContainerConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        cameraPreviewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: nil, metrics: metrics, views: views))
        cameraPreviewContainer.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .Bottom, relatedBy: .Equal, toItem: cameraPreviewContainer, attribute: .Bottom, multiplier: 1, constant: -20))
    }
    
    private func configureBottomControlsConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        if videoEnabled {
            // Mode Buttons
            bottomControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[videoModeButton]-(20)-[photoModeButton]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
            centerModeButtonConstraint = NSLayoutConstraint(item: photoModeButton, attribute: .CenterX, relatedBy: .Equal, toItem: takePhotoButton, attribute: .CenterX, multiplier: 1, constant: 0)
            bottomControlsView.addConstraint(centerModeButtonConstraint!)
            bottomControlsView.addConstraint(NSLayoutConstraint(item: photoModeButton, attribute: .Bottom, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Top, multiplier: 1, constant: -5))
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Top, relatedBy: .Equal, toItem: photoModeButton, attribute: .Top, multiplier: 1, constant: -5))
        } else {
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Top, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Top, multiplier: 1, constant: 0))
        }
        
        // CameraRollButton
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .CenterY, relatedBy: .Equal, toItem: takePhotoButton, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Left, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Left, multiplier: 1, constant: 20))
        
        // TakePhotoButton
        bottomControlsView.addConstraint(NSLayoutConstraint(item: takePhotoButton, attribute: .CenterX, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterX, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Bottom, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Bottom, multiplier: 1, constant: 10))
        
        // RecordVideoButton
        bottomControlsView.addConstraint(NSLayoutConstraint(item: recordVideoButton, attribute: .Top, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Top, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: recordVideoButton, attribute: .Right, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Right, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: recordVideoButton, attribute: .Bottom, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Bottom, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: recordVideoButton, attribute: .Left, relatedBy: .Equal, toItem: takePhotoButton, attribute: .Left, multiplier: 1, constant: 0))
        
        // FilterSelectionButton
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .CenterY, relatedBy: .Equal, toItem: takePhotoButton, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Right, relatedBy: .Equal, toItem: filterSelectionButton, attribute: .Right, multiplier: 1, constant: 20))
    }
    
    private func configureCameraController() {
        // Needed so that the framebuffer can bind to OpenGL ES
        view.layoutIfNeeded()
        
        cameraController = IMGLYCameraController(previewView: cameraPreviewContainer)
        cameraController!.delegate = self
        cameraController!.setup()
    }
    
    private func configureFilterSelectionController() {
        filterSelectionController.selectedBlock = { [weak self] filterType in
            if let cameraController = self?.cameraController where cameraController.effectFilter.filterType != filterType {
                cameraController.effectFilter = IMGLYInstanceFactory.effectFilterWithType(filterType)
                cameraController.effectFilter.inputIntensity = InitialFilterIntensity
                self?.filterIntensitySlider.value = InitialFilterIntensity
            }
            
            if filterType == .None {
                self?.hideSliderTimer?.invalidate()
                if let filterIntensitySlider = self?.filterIntensitySlider where filterIntensitySlider.alpha > 0 {
                    UIView.animateWithDuration(0.25) {
                        filterIntensitySlider.alpha = 0
                    }
                }
            } else {
                if let filterIntensitySlider = self?.filterIntensitySlider where filterIntensitySlider.alpha < 1 {
                    UIView.animateWithDuration(0.25) {
                        filterIntensitySlider.alpha = 1
                    }
                }
                
                self?.resetHideSliderTimer()
            }
        }
        
        filterSelectionController.activeFilterType = { [weak self] in
            if let cameraController = self?.cameraController {
                return cameraController.effectFilter.filterType
            } else {
                return .None
            }
        }
    }
    
    // MARK: - Helpers
    
    private func updateFlashButton() {
        if let cameraController = cameraController {
            flashButton.hidden = !cameraController.flashAvailable
            
            let bundle = NSBundle(forClass: self.dynamicType)
            
            switch(cameraController.flashMode) {
            case .Auto:
                self.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            case .On:
                self.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            case .Off:
                self.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            }
        } else {
            flashButton.hidden = true
        }
    }
    
    private func resetHideSliderTimer() {
        hideSliderTimer?.invalidate()
        hideSliderTimer = NSTimer.scheduledTimerWithTimeInterval(ShowFilterIntensitySliderInterval, target: self, selector: "hideFilterIntensitySlider:", userInfo: nil, repeats: false)
    }
    
    private func showEditorNavigationControllerWithImage(image: UIImage?) {
        let editorViewController = IMGLYMainEditorViewController()
        editorViewController.highResolutionImage = image
        if let cameraController = cameraController {
            editorViewController.initialFilterType = cameraController.effectFilter.filterType
            editorViewController.initialFilterIntensity = cameraController.effectFilter.inputIntensity
        }
        editorViewController.completionBlock = editorCompletionBlock
        
        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    public func setLastImageFromRollAsPreview() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        if fetchResult.lastObject != nil {
            let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: CGSize(width: BottomControlSize.width * 2, height: BottomControlSize.height * 2), contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.cameraRollButton.setImage(result, forState: UIControlState.Normal)
            }
        }
    }
    
    // MARK: - Targets
    
    @objc private func toggleMode(sender: AnyObject?) {
        if let gestureRecognizer = sender as? UISwipeGestureRecognizer {
            if gestureRecognizer.direction == .Left {
                recordingMode = .Photo
            } else if gestureRecognizer.direction == .Right {
                recordingMode = .Video
            }
        }
        
        if let button = sender as? UIButton where button == photoModeButton {
            recordingMode = .Photo
        } else if let button = sender as? UIButton where button == videoModeButton {
            recordingMode = .Video
        }
    }
    
    @objc private func hideFilterIntensitySlider(timer: NSTimer?) {
        UIView.animateWithDuration(0.25) {
            self.filterIntensitySlider.alpha = 0
            self.hideSliderTimer = nil
        }
    }
    
    public func changeFlash(sender: UIButton?) {
        cameraController?.selectNextFlashMode()
    }
    
    public func switchCamera(sender: UIButton?) {
        cameraController?.toggleCameraPosition()
    }
    
    public func showCameraRoll(sender: UIButton?) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage]
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    public func takePhoto(sender: UIButton?) {
        cameraController?.takePhoto { image, error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if let completionBlock = self.completionBlock {
                        completionBlock(image)
                    } else {
                        self.showEditorNavigationControllerWithImage(image)
                    }
                }
            }
        }
    }
    
    public func recordVideo(sender: IMGLYVideoRecordButton?) {
        if let recordVideoButton = sender {
            if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
                toggleFilters(filterSelectionButton)
            }
            
            UIView.animateWithDuration(0.25) {
                if recordVideoButton.recording {
                    self.cameraRollButton.alpha = 0
                    self.videoModeButton.alpha = 0
                    self.photoModeButton.alpha = 0
                    self.filterSelectionButton.alpha = 0
                } else {
                    self.cameraRollButton.alpha = 1
                    self.videoModeButton.alpha = 1
                    self.photoModeButton.alpha = 1
                    self.filterSelectionButton.alpha = 1
                }
            }
        }
    }
    
    public func toggleFilters(sender: UIButton?) {
        if let filterSelectionViewConstraint = self.filterSelectionViewConstraint {
            let animationDuration = NSTimeInterval(0.6)
            let dampingFactor = CGFloat(0.6)
            
            if filterSelectionViewConstraint.constant == 0 {
                // Expand
                filterSelectionController.beginAppearanceTransition(true, animated: true)
                filterSelectionViewConstraint.constant = -1 * CGFloat(FilterSelectionViewHeight)
                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: nil, animations: {
                    sender?.transform = CGAffineTransformIdentity
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        self.filterSelectionController.endAppearanceTransition()
                })
            } else {
                // Close
                filterSelectionController.beginAppearanceTransition(false, animated: true)
                filterSelectionViewConstraint.constant = 0
                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: nil, animations: {
                    sender?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        self.filterSelectionController.endAppearanceTransition()
                })
            }
        }
    }
    
    @objc private func changeIntensity(sender: UISlider?) {
        if let slider = sender {
            resetHideSliderTimer()
            cameraController?.effectFilter.inputIntensity = slider.value
        }
    }
    
    // MARK: - Completion
    
    private func editorCompletionBlock(result: IMGLYEditorResult, image: UIImage?) {
        if let image = image where result == .Done {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>) {
        setLastImageFromRollAsPreview()
    }

}

extension IMGLYCameraViewController: IMGLYCameraControllerDelegate {
    public func cameraControllerDidStartCamera(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = true
        }
    }
    
    public func cameraControllerDidStopCamera(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = false
        }
    }
    
    public func cameraControllerDidStartStillImageCapture(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.takePhotoButton.imageView?.startAnimating()
            self.buttonsEnabled = false
        }
    }
    
    public func cameraControllerDidFailAuthorization(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            let bundle = NSBundle(forClass: self.dynamicType)

            let alertController = UIAlertController(title: NSLocalizedString("camera-view-controller.camera-no-permission.title", tableName: nil, bundle: bundle, value: "", comment: ""), message: NSLocalizedString("camera-view-controller.camera-no-permission.message", tableName: nil, bundle: bundle, value: "", comment: ""), preferredStyle: .Alert)
            
            let settingsAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.settings", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Default) { _ in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.cancel", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, didChangeToFlashMode flashMode: AVCaptureFlashMode) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateFlashButton()
        }
    }
    
    public func cameraControllerDidCompleteSetup(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateFlashButton()
            self.switchCameraButton.hidden = !cameraController.moreThanOneCameraPresent
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, willSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = false
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, didSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = true
            self.updateFlashButton()
        }
    }
}

extension IMGLYCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: {
            if let completionBlock = self.completionBlock {
                completionBlock(image)
            } else {
                self.showEditorNavigationControllerWithImage(image)
            }
        })
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
