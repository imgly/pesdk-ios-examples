//
//  CameraViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 30/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

public typealias IMGLYCameraCompletionBlock = (UIImage?)->Void

public class IMGLYCameraViewController: UIViewController, IMGLYCameraViewDelegate, IMGFilterSelectorViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, IMGLYCameraControllerDelegate {
    
    public var completionBlock:IMGLYCameraCompletionBlock? = nil
    
    private var cameraView_:IMGLYCameraView?
    private var cameraController_:IMGLYCameraController?
    private var image_:UIImage?
    private var currentCameraPosition_:AVCaptureDevicePosition = AVCaptureDevicePosition.Front
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.extendedLayoutIncludesOpaqueBars = true;
        UIApplication.sharedApplication().statusBarHidden = true;
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func loadView() {
        self.view = IMGLYCameraView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraView()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cameraView_!.setLastImageFromRollAsPreview()
        cameraController_!.startCaptureSession()
        cameraView_!.enableButtons()
        cameraView_!.setNeedsDisplay()
    }
    
    public func setupCameraView() {
        if let cameraView = self.view as? IMGLYCameraView {
            cameraView_ = self.view as? IMGLYCameraView
            cameraController_ = IMGLYCameraController(previewView: cameraView_!.streamPreview)
            cameraController_!.delegate = self
            if cameraController_!.isCameraPresentWithPosition(AVCaptureDevicePosition.Back) {
                cameraController_!.setupWithCameraPosition(AVCaptureDevicePosition.Back)
                currentCameraPosition_ = AVCaptureDevicePosition.Back
            } else {
                cameraController_!.setupWithCameraPosition(AVCaptureDevicePosition.Front)
                currentCameraPosition_ = AVCaptureDevicePosition.Front
            }
            cameraView_!.filterSelectorView.commonInit()
            cameraView_!.filterSelectorView.delegate = self
            cameraView_!.delegate = self
            cameraView_!.toggleCameraButton.hidden = !cameraController_!.isMoreThanOneCameraPresent()
            cameraView_!.flashModeButton.hidden = !cameraController_!.isFlashPresent()
        }
    }
    
    // MARK:- IMGLYCameraViewDelegate
    public func takePhotoButtonPressed() {
        self.cameraView_!.disableButtons()
        self.cameraView_!.setNeedsDisplay()
        cameraController_!.takePhoto { (image, error) -> Void in
            if error == nil {
                self.cameraController_!.stopCaptureSession()
                self.image_ = image
                dispatch_async(dispatch_get_main_queue(), {
                    [unowned self] in
                    if self.completionBlock == nil {
                        self.showModalEditorNavigationController()
                    }
                    else {
                        self.completionBlock!(image)
                    }
                })
            }
        }
    }
  
    public func toggleFilterButtonPressed() {
        
    }
    
    public func toggleCameraButtonPressed() {
        self.cameraView_!.disableButtons()
        self.cameraController_!.toggleCameraPosition()
    }
    
    public func flashModeButtonPressed() {
        cameraController_!.selectNextFlashmode()
    }
    
    public func selectFromRollButtonPressed() {
        selectImageFromCameraRoll()
    }
    
    public func selectImageFromCameraRoll() {
        cameraController_!.stopCaptureSession()
        let imagePicker:UIImagePickerController = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage]
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true,
            completion: nil)
    }
    
    // MARK:- UIImagePickerControllerDelegate
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image_ = image
        }
        
        self.dismissViewControllerAnimated(true, completion: {
            UIApplication.sharedApplication().statusBarHidden = true
            if self.completionBlock == nil {
                self.showModalEditorNavigationController()
            }
            else {
                self.completionBlock!(self.image_!)
            }
        })
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: {
            UIApplication.sharedApplication().statusBarHidden = true
        })
    }
    
    // MARK:- IMGFilterSelectorViewDelegate
    public func didSelectFilter(filter:IMGLYFilterType) {
        if let effectFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(filter) as? IMGLYResponseFilter {
            cameraController_!.effectFilter = effectFilter
            cameraView_!.toggleFilterLabel.text = effectFilter.displayName
        }
        cameraController_!.effectFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(filter)
    }
    
    private func showModalEditorNavigationController() {
        let editorViewController = IMGLYEditorMainDialogViewController()
        editorViewController.hiResImage = image_
        editorViewController.initialFilterType = cameraView_!.filterSelectorView.activeFilterType
        editorViewController.completionBlock = editorCompletionBlock
        image_ = nil
        
        self.showViewController(editorViewController, sender: nil)
    }
    
    // MARK:- IMGLYCameraControllerDelegate
    public func captureSessionStarted() {
        dispatch_async(dispatch_get_main_queue()) {
            self.cameraView_!.enableButtons()
        }
    }
    
    public func captureSessionStopped() {
        
    }
    
    public func willToggleCamera() {
        
    }
    
    public func didToggleCamera() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.cameraController_!.isFlashPresent() {
                println("flash present")
                self.cameraView_!.flashModeButton.hidden = false
            }
            else {
                println("not present")
                self.cameraView_!.flashModeButton.hidden = true
            }
        }
    }
    
    public func didSetFlashMode(flashMode:AVCaptureFlashMode) {
       
            cameraView_!.setFlashMode(flashMode)
        
    }
    
    // MARK:- Completion
    public func editorCompletionBlock(result:IMGLYEditorResult, image:UIImage?) {
        if result == IMGLYEditorResult.Done && image != nil {
            UIImageWriteToSavedPhotosAlbum(image, self, "imageSaved:didFinishSavingWithError:contextInfo:", nil);
        }
    }
    
    public func imageSaved(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>) {
        cameraView_!.setLastImageFromRollAsPreview()
    }
}
