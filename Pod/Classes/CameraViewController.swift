//
//  CameraViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)
public typealias CameraCompletionBlock = (UIImage?) -> (Void)

@objc(IMGLYCameraViewController) public class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    public private(set) lazy var topControlsView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    public private(set) lazy var cameraPreviewContainer: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        return button
        }()
    
    public private(set) lazy var switchCameraButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "cam_switch", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.contentHorizontalAlignment = .Right
        button.addTarget(self, action: "switchCamera:", forControlEvents: .TouchUpInside)
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
    
    private var filterSelectionViewConstraint: NSLayoutConstraint?
    public let filterSelectionController = FilterSelectionController()
    
    private var currentCameraPosition = AVCaptureDevicePosition.Front
    public private(set) var cameraController: CameraController?
    
    private var buttonsEnabled = true {
        didSet {
            flashButton.enabled = buttonsEnabled
            switchCameraButton.enabled = buttonsEnabled
            cameraRollButton.enabled = buttonsEnabled
            takePhotoButton.enabled = buttonsEnabled
            filterSelectionController.view.userInteractionEnabled = buttonsEnabled
            filterSelectionButton.enabled = buttonsEnabled
        }
    }
    
    public var completionBlock: CameraCompletionBlock?
    
    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewHierarchy()
        configureViewConstraints()
        configureFilterSelectionController()
        configureCameraController()
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
        cameraController?.startCaptureSession()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        
        bottomControlsView.addSubview(cameraRollButton)
        bottomControlsView.addSubview(takePhotoButton)
        bottomControlsView.addSubview(filterSelectionButton)
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
            "filterSelectionButton" : filterSelectionButton
        ]
        
        let metrics: [NSObject : NSNumber] = [
            "topControlsViewHeight" : 44,
            "bottomControlsViewHeight" : 100,
            "filterSelectionViewHeight" : FilterSelectionViewHeight,
            "topControlMargin" : 20,
            "topControlMinWidth" : 44
        ]
        
        configureSuperviewConstraintsWithMetrics(metrics, views: views)
        configureTopControlsConstraintsWithMetrics(metrics, views: views)
        configureBottomControlsConstraintsWithMetrics(metrics, views: views)
    }
    
    private func configureSuperviewConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[topControlsView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[cameraPreviewContainer]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomControlsView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: nil, metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][topControlsView(==topControlsViewHeight)][cameraPreviewContainer][bottomControlsView(==bottomControlsViewHeight)][filterSelectionView(==filterSelectionViewHeight)]", options: nil, metrics: metrics, views: views))
        
        filterSelectionViewConstraint = NSLayoutConstraint(item: filterSelectionController.view, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(filterSelectionViewConstraint!)
    }
    
    private func configureTopControlsConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==topControlMargin)-[flashButton(>=topControlMinWidth)]-(>=topControlMargin)-[switchCameraButton(>=topControlMinWidth)]-(==topControlMargin)-|", options: nil, metrics: metrics, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flashButton]|", options: nil, metrics: nil, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[switchCameraButton]|", options: nil, metrics: nil, views: views))
    }
    
    private func configureBottomControlsConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        // CameraRollButton
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Left, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Left, multiplier: 1, constant: 20))
        
        // TakePhotoButton
        bottomControlsView.addConstraint(NSLayoutConstraint(item: takePhotoButton, attribute: .CenterX, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterX, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: takePhotoButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        // FilterSelectionButton
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Right, relatedBy: .Equal, toItem: filterSelectionButton, attribute: .Right, multiplier: 1, constant: 20))
    }
    
    private func configureCameraController() {
        // Needed so that the framebuffer can bind to OpenGL ES
        view.layoutIfNeeded()
        
        cameraController = CameraController(previewView: cameraPreviewContainer)
        cameraController!.delegate = self
        if cameraController!.isCameraPresentWithPosition(AVCaptureDevicePosition.Back) {
            cameraController!.setupWithCameraPosition(AVCaptureDevicePosition.Back)
            currentCameraPosition = AVCaptureDevicePosition.Back
        } else {
            cameraController!.setupWithCameraPosition(AVCaptureDevicePosition.Front)
            currentCameraPosition = AVCaptureDevicePosition.Front
        }
        
        switchCameraButton.hidden = !cameraController!.isMoreThanOneCameraPresent()
        flashButton.hidden = !cameraController!.isFlashPresent()
    }
    
    private func configureFilterSelectionController() {
        filterSelectionController.selectedBlock = { [unowned self] filterType in
            self.cameraController?.effectFilter = InstanceFactory.sharedInstance.effectFilterWithType(filterType)
        }
        
        filterSelectionController.activeFilterType = { [unowned self] in
            if let cameraController = self.cameraController {
                return cameraController.effectFilter.filterType
            } else {
                return .None
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showEditorNavigationControllerWithImage(image: UIImage?) {
        let editorViewController = MainEditorViewController()
        editorViewController.highResolutionImage = image
        editorViewController.initialFilterType = cameraController?.effectFilter.filterType
        editorViewController.completionBlock = editorCompletionBlock
        
        let navigationController = NavigationController(rootViewController: editorViewController)
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
    
    public func changeFlash(sender: UIButton?) {
        cameraController?.selectNextFlashmode()
    }
    
    public func switchCamera(sender: UIButton?) {
        buttonsEnabled = false
        cameraController?.toggleCameraPosition()
    }
    
    public func showCameraRoll(sender: UIButton?) {
        cameraController?.stopCaptureSession()
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage]
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    public func takePhoto(sender: UIButton?) {
        sender?.imageView?.startAnimating()
        
        buttonsEnabled = false
        
        cameraController?.takePhoto { (image, error) -> Void in
            if error == nil {
                self.cameraController?.stopCaptureSession()
                dispatch_async(dispatch_get_main_queue(), {
                    [unowned self] in
                    if let completionBlock = self.completionBlock {
                        completionBlock(image)
                    } else {
                        self.showEditorNavigationControllerWithImage(image)
                    }
                    })
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
    
    // MARK: - Completion
    private func editorCompletionBlock(result: EditorResult, image: UIImage?) {
        if let image = image where result == EditorResult.Done {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil);
        }
    }
    
    @objc private func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>) {
        setLastImageFromRollAsPreview()
    }

}

extension CameraViewController: CameraControllerDelegate {
    public func captureSessionStarted() {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = true
        }
    }
    
    public func captureSessionStopped() {
        
    }
    
    public func willToggleCamera() {
        
    }
    
    public func didToggleCamera() {
        dispatch_async(dispatch_get_main_queue()) {
            if let cameraController = self.cameraController where cameraController.isFlashPresent() {
                self.flashButton.hidden = false
            }
            else {
                self.flashButton.hidden = true
            }
        }
    }
    
    public func didSetFlashMode(flashMode: AVCaptureFlashMode) {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        switch(flashMode) {
        case AVCaptureFlashMode.Auto:
            self.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection:nil), forState: UIControlState.Normal)
        case AVCaptureFlashMode.On:
            self.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection:nil), forState: UIControlState.Normal)
        case AVCaptureFlashMode.Off:
            self.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection:nil), forState: UIControlState.Normal)
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
