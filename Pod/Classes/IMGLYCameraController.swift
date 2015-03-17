//
//  IMGLYCameraController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 01/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit
import AVFoundation

public protocol IMGLYCameraControllerDelegate: class {
    func captureSessionStarted()
    func captureSessionStopped()
    func willToggleCamera()
    func didToggleCamera()
    func didSetFlashMode(flashMode:AVCaptureFlashMode)
}

/**
    The camera-controller takes care about the communication with the capture devices.
    It provides methods to start a capture session, toggle between cameras, or select a flash mode.
*/
public class IMGLYCameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public weak var delegate: IMGLYCameraControllerDelegate?
    
    // MARK:- private vars
    private var previewView_:UIView?
    private var glContext_ : EAGLContext!
    private var videoPreviewView_ : GLKView!
    private var ciContext_ : CIContext!
    private var captureSession_ : AVCaptureSession?
    private var captureSessionQueue_ : dispatch_queue_t?
    private var videoDevice_: AVCaptureDevice?
    private var currentVideoDimensions_ : CMVideoDimensions?
    private var activeFilters_: [CIFilter]  = []
    private var videoDeviceInput_: AVCaptureDeviceInput!
    private var videoDataOutput_: AVCaptureVideoDataOutput!
    private var stillImageOutput_: AVCaptureStillImageOutput!
    private var cameraPosition_: AVCaptureDevicePosition
    private var videoPreviewAdded_ = false
    //private var flashMode_ = AVCaptureFlashMode.Auto
    private var flashModeIndex_ = 0
    private var supportedFlashModes_:[AVCaptureFlashMode] =  []
    
    // MARK:- computed vars
    private var effectFilter_: CIFilter?
    /// The response filter that is applied to the live-feed.
    public var effectFilter: CIFilter? {
        set(filter) {
            effectFilter_ = filter
            // if we set filter to nil we remove the effect filter section completly
            if (filter == nil) {
                if activeFilters_.count > 1 {
                    activeFilters_.removeLast()
                }
            } else {
                if activeFilters_.count > 1 {
                    activeFilters_[1] = filter!
                } else {
                    activeFilters_.append(filter!)
                }
            }
        }
        get {
            return effectFilter_;
        }
    }
    
    public struct Statics {
        public static var sDeviceRgbColorSpace : CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
    }
    
    // MARK:- init functions
    public init(previewView: UIView) {
        previewView_ = previewView
        cameraPosition_ = AVCaptureDevicePosition.Unspecified
        super.init()
    }
    
    // MARK:- setup code
    /**
    Call this in view did load of your view controller.
    
    :param: cameraPosition The camera position.
    */
    public func setupWithCameraPosition(cameraPosition:AVCaptureDevicePosition) {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            cameraPosition_ = cameraPosition
            setupVideoPreview()
            setupVideoInputsAndSession()
        #endif
    }
    
    private func setupVideoInputsAndSession() {
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if videoDevices.count > 0 {
            setupAndStartCaptureSession()
            setupFilterStack()
        }
    }
    
    private func setupFilterStack() {
        var videoSource = IMGLYSourceVideoFilter()
        activeFilters_ = [videoSource]
    }

    private func setupVideoPreview() {
        if !videoPreviewAdded_ {
            let window = (UIApplication.sharedApplication().delegate?.window!)!
            glContext_ = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
            videoPreviewView_ = GLKView(frame: CGRectZero, context: glContext_)
            videoPreviewView_.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            
            let transformation = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            videoPreviewView_.transform = transformation;
            
            if previewView_ != nil {
                videoPreviewView_!.frame = previewView_!.bounds
                previewView_!.addSubview(videoPreviewView_)
            } else {
                videoPreviewView_!.frame = window.bounds
                window.addSubview(videoPreviewView_)
            }
            
            // create the CIContext instance, note that this must be done after videoPreviewView_ is properly set up
            let options = [kCIContextWorkingColorSpace : NSNull()]
            ciContext_ = CIContext(EAGLContext: glContext_, options:options)
            videoPreviewView_.bindDrawable()
            videoPreviewAdded_ = true
        }
    }
    
    private func setupAndStartCaptureSession() {
        if (captureSessionQueue_ == nil) {
            captureSessionQueue_ = dispatch_queue_create("capture_session_queue", nil);
        }
        
        dispatch_async(captureSessionQueue_!) {
            var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            self.videoDevice_  = nil
            
            for device in videoDevices {
                if device.position == self.cameraPosition_ {
                    self.videoDevice_ = device as? AVCaptureDevice
                }
            }
            
            self.updateSupportedFlashModeList()
            
            let preset = AVCaptureSessionPresetPhoto;
            if !self.videoDevice_!.supportsAVCaptureSessionPreset(preset) {
                println("Session preset not supported")
                return
            }
            self.setupCaptureSessionWithPreset(preset)
            self.addVideoInput()
            self.addVideoOutput()
            self.addStillImageOutput()
            
            self.captureSession_!.commitConfiguration()
            self.captureSession_!.startRunning()
            self.delegate?.captureSessionStarted()
            
            if self.isFlashPresent() {
                self.matchFlashmodeIfPossible()
                self.updateFlashMode()
            }
            
            self.delegate?.didToggleCamera()
        }
    }
    
    private func setupCaptureSessionWithPreset(preset:NSString!) {
        self.captureSession_ = AVCaptureSession()
        self.captureSession_!.sessionPreset = preset as! String
        self.captureSession_?.beginConfiguration()
    }
    
    private func addVideoInput() {
        var error : NSError? = nil
        self.videoDeviceInput_ = AVCaptureDeviceInput(device: self.videoDevice_, error: &error)
        if self.videoDeviceInput_ == nil {
            println("Error \(error?.description)")
        }
        self.captureSession_!.addInput(videoDeviceInput_)
    }
    
    
    private func addVideoOutput() {
        self.videoDataOutput_ = AVCaptureVideoDataOutput()
        self.videoDataOutput_.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
        self.videoDataOutput_.alwaysDiscardsLateVideoFrames = true
        
        self.videoDataOutput_.setSampleBufferDelegate(self, queue:self.captureSessionQueue_)
        
        if (self.captureSession_?.canAddOutput(self.videoDataOutput_) != nil) {
            self.captureSession_?.addOutput(self.videoDataOutput_)
        }
    }
    
    private func addStillImageOutput() {
        stillImageOutput_ = AVCaptureStillImageOutput()
        stillImageOutput_.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if (self.captureSession_?.canAddOutput(self.stillImageOutput_) != nil) {
            self.captureSession_?.addOutput(self.stillImageOutput_)
        }
    }
    
    /**
    Use this function to determin weather a camera with the desired position is available.
    :param: cameraPosition The desired camera position.
    
    :returns: True is a camera with the specified position is available, false otherwise.
    */
    public func isCameraPresentWithPosition(cameraPosition:AVCaptureDevicePosition) -> Bool {
        var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var foundMatch = false
        
        for device in videoDevices {
            if device.position == cameraPosition {
                foundMatch = true
            }
        }
        return foundMatch
    }
    
    /**
    Use this function to determin weather more than one camera is available.
    Within the SDK this method is used to determin if the toggle button is visible.
    
    :returns: True if more than one camera is present, false otherwise.
    */
    public func isMoreThanOneCameraPresent() -> Bool {
        var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        return (videoDevices.count > 1)
    }
    
    /**
    Check if the current device has a flash.
    
    :returns: True if a flash is presen, false otherwise.
    */
    public func isFlashPresent() -> Bool {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            return videoDevice_!.hasFlash
        #else
            return true
        #endif
    }
    
    //  MARK:- session handling
    
    /**
    Starts the capture session.
    */
    public func startCaptureSession() {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            if (!self.captureSession_!.running) {
                self.captureSession_!.startRunning()
                self.delegate?.captureSessionStarted()
            }
        #else
            println("startCaptureSession called")
        #endif
    }
    
    /**
    Stops the capture session.
    */
    public func stopCaptureSession() {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            if (self.captureSession_!.running) {
                self.delegate?.captureSessionStopped()
                self.captureSession_!.stopRunning()
            }
            #else
            println("stopCaptureSession called")
        #endif
    }
    
    /**
    Toggle between front and back camera.
    */
    public func toggleCameraPosition() {
        delegate?.willToggleCamera()
        if cameraPosition_ == AVCaptureDevicePosition.Back {
            stopCaptureSession()
            cameraPosition_ = .Front
            setupWithCameraPosition(AVCaptureDevicePosition.Front)
        } else {
            stopCaptureSession()
            cameraPosition_ = .Back
            setupWithCameraPosition(AVCaptureDevicePosition.Back)
        }
    }
    
    /**
    Selects the next flash-mode. The order is Auto->On->Off. 
    If the current device does not support auto-flash, this method
    just toggles between on and off.
    */
    public func selectNextFlashmode() {
        flashModeIndex_ = (flashModeIndex_ + 1) % supportedFlashModes_.count
        updateFlashMode()
    }
    
   private func updateFlashMode() {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            var error:NSError? = nil
            self.captureSession_?.beginConfiguration()
            videoDevice_!.lockForConfiguration(&error)
            videoDevice_!.flashMode = supportedFlashModes_[flashModeIndex_]
            videoDevice_!.unlockForConfiguration()
            self.captureSession_?.commitConfiguration()
            if supportedFlashModes_.count > 0 {
                delegate?.didSetFlashMode(supportedFlashModes_[flashModeIndex_])
            } 
        #endif
    }

    private func updateSupportedFlashModeList() {
        supportedFlashModes_ = []
        if isFlashPresent() {
            if videoDevice_!.isFlashModeSupported(AVCaptureFlashMode.Auto) {
                supportedFlashModes_.append(AVCaptureFlashMode.Auto)
            }
            if videoDevice_!.isFlashModeSupported(AVCaptureFlashMode.On) {
                supportedFlashModes_.append(AVCaptureFlashMode.On)
            }
            if videoDevice_!.isFlashModeSupported(AVCaptureFlashMode.Off) {
                supportedFlashModes_.append(AVCaptureFlashMode.Off)
            }
        }
    }
    
    private func matchFlashmodeIfPossible() {
        if supportedFlashModes_.count == 0 {
            return
        }
        var flashMode = supportedFlashModes_[flashModeIndex_]
        var matched = false
        
        // if the selected mode is still supported choose it again
        for var i = 0; i < supportedFlashModes_.count; i++ {
            var mode = supportedFlashModes_[i]
            if mode == flashMode {
                flashModeIndex_ = i
                matched = true
                break
            }
        }
        
        if !matched {
            flashModeIndex_ = 0
        }
    }
    
    // MARK:- photo taking
    /**
    Takes a photo and hands it over to the completion block.
    
    :param: completion A completion block that has an image and an error as parameters. 
    If the image was taken sucessfuly, the error is nil.
    */
    public func takePhoto(completion:((image: UIImage?, error: NSError?) -> Void)?) {
        if completion == nil || self.stillImageOutput_ == nil {
            return
        }
        var imageOrientation = imageOrientationForDeviceOrientation(UIDevice.currentDevice().orientation)

        dispatch_async(self.captureSessionQueue_!, {
            self.stillImageOutput_.captureStillImageAsynchronouslyFromConnection(
                self.stillImageOutput_.connectionWithMediaType(AVMediaTypeVideo),completionHandler: {
                    (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
                    if imageDataSampleBuffer == nil || error != nil {
                        completion!(image:nil, error:error)
                    }
                    else if imageDataSampleBuffer != nil {
                        var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        var image = UIImage(data: imageData)!
                        var orientedImage = UIImage(CGImage: image.CGImage, scale: 1.0, orientation: imageOrientation)
                        completion!(image:orientedImage, error:nil)
                    }
                }
            )
        })
    }
    
 
    private func imageOrientationForDeviceOrientation(orientation:UIDeviceOrientation) -> UIImageOrientation {
        var result = UIImageOrientation.Right
        switch (orientation) {
        case UIDeviceOrientation.Unknown:
            result = UIImageOrientation.Right
        case UIDeviceOrientation.Portrait: // Device oriented vertically, home button on the bottom
            result = UIImageOrientation.Right
        case UIDeviceOrientation.PortraitUpsideDown: // Device oriented vertically, home button on the top
            result = UIImageOrientation.Left
        case UIDeviceOrientation.LandscapeLeft: // Device oriented horizontally, home button on the right
            result = UIImageOrientation.Up
        case UIDeviceOrientation.LandscapeRight: // Device oriented horizontally, home button on the left
            result = UIImageOrientation.Down
        case UIDeviceOrientation.FaceUp: // Device oriented flat, face up
            result = UIImageOrientation.Right
        case UIDeviceOrientation.FaceDown: // Dev
            result = UIImageOrientation.Right
        }
        return result
    }

    
    // MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
        currentVideoDimensions_ = CMVideoFormatDescriptionGetDimensions(formatDesc)
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let sourceImage = CIImage(CVPixelBuffer:imageBuffer as CVPixelBufferRef, options: nil)
        let filteredImage:CIImage? = IMGLYPhotoProcessor.processWithCIImage(sourceImage, filters:activeFilters_)
        let sourceExtent = sourceImage.extent()
        
        var scale = CGFloat(videoPreviewView_.drawableWidth) / CGRectGetWidth(sourceExtent)
        if CGRectGetHeight(sourceExtent) * scale > CGFloat(videoPreviewView_.drawableHeight) {
            scale = CGFloat(videoPreviewView_.drawableHeight) / CGRectGetHeight(sourceExtent)
        }
        
        let scaledWidth = CGRectGetWidth(sourceExtent) * scale
        let scaledHeight = CGRectGetHeight(sourceExtent) * scale
        let scaledX = CGFloat(videoPreviewView_.drawableWidth) / 2 - scaledWidth / 2
        let scaledY = CGFloat(videoPreviewView_.drawableHeight) / 2 - scaledHeight / 2;
        
        let scaledRect = CGRect(x: scaledX, y: scaledY, width: scaledWidth, height: scaledHeight)

        videoPreviewView_.bindDrawable()
        if glContext_ != EAGLContext.currentContext() {
            EAGLContext.setCurrentContext(glContext_)
        }
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        if filteredImage != nil {
            ciContext_.drawImage(filteredImage!, inRect:scaledRect, fromRect:sourceExtent)
        }
        videoPreviewView_.display()
    }
    
}
