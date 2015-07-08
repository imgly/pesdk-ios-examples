//
//  IMGLYCameraController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 15/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import OpenGLES
import GLKit
import CoreMotion

struct IMGLYSDKVersion: Comparable, Printable {
    let majorVersion: Int
    let minorVersion: Int
    let patchVersion: Int
    
    var description: String {
        return "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
}

func ==(lhs: IMGLYSDKVersion, rhs: IMGLYSDKVersion) -> Bool {
    return (lhs.majorVersion == rhs.majorVersion) && (lhs.minorVersion == rhs.minorVersion) && (lhs.patchVersion == rhs.patchVersion)
}

func <(lhs: IMGLYSDKVersion, rhs: IMGLYSDKVersion) -> Bool {
    if lhs.majorVersion < rhs.majorVersion {
        return true
    } else if lhs.majorVersion > rhs.majorVersion {
        return false
    }
    
    if lhs.minorVersion < rhs.minorVersion {
        return true
    } else if lhs.minorVersion > rhs.minorVersion {
        return false
    }
    
    if lhs.patchVersion < rhs.patchVersion {
        return true
    } else if lhs.patchVersion > rhs.patchVersion {
        return false
    }
    
    return false
}

let CurrentSDKVersion = IMGLYSDKVersion(majorVersion: 2, minorVersion: 2, patchVersion: 1)

private let kIMGLYIndicatorSize = CGFloat(75)
private var CapturingStillImageContext = 0
private var SessionRunningAndDeviceAuthorizedContext = 0
private var FocusAndExposureContext = 0

@objc public protocol IMGLYCameraControllerDelegate: class {
    optional func cameraControllerDidStartCamera(cameraController: IMGLYCameraController)
    optional func cameraControllerDidStopCamera(cameraController: IMGLYCameraController)
    optional func cameraControllerDidStartStillImageCapture(cameraController: IMGLYCameraController)
    optional func cameraControllerDidFailAuthorization(cameraController: IMGLYCameraController)
    optional func cameraController(cameraController: IMGLYCameraController, didChangeToFlashMode flashMode: AVCaptureFlashMode)
    optional func cameraControllerDidCompleteSetup(cameraController: IMGLYCameraController)
    optional func cameraController(cameraController: IMGLYCameraController, willSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition)
    optional func cameraController(cameraController: IMGLYCameraController, didSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition)
}

public typealias IMGLYTakePhotoBlock = (UIImage?, NSError?) -> Void

public class IMGLYCameraController: NSObject {
    
    // MARK: - Properties
    
    /// The response filter that is applied to the live-feed.
    public var effectFilter: IMGLYResponseFilter = IMGLYNoneFilter()
    public let previewView: UIView
    public weak var delegate: IMGLYCameraControllerDelegate?
    public let tapGestureRecognizer = UITapGestureRecognizer()
    
    dynamic private let session = AVCaptureSession()
    private let sessionQueue = dispatch_queue_create("capture_session_queue", nil)
    private let sampleBufferQueue = dispatch_queue_create("sample_buffer_queue", nil)
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    dynamic private var stillImageOutput: AVCaptureStillImageOutput?
    private var runtimeErrorHandlingObserver: NSObjectProtocol?
    dynamic private var deviceAuthorized = false
    private var glContext: EAGLContext?
    private var ciContext: CIContext?
    private var videoPreviewView: GLKView?
    private var setupComplete = false
    private var videoPreviewFrame = CGRectZero
    private let focusIndicatorLayer = CALayer()
    private var focusIndicatorFadeOutTimer: NSTimer?
    private var focusIndicatorAnimating = false
    private let motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
        return motionManager
        }()
    private let motionManagerQueue = NSOperationQueue()
    private var captureVideoOrientation: AVCaptureVideoOrientation?
    
    dynamic private var sessionRunningAndDeviceAuthorized: Bool {
        return session.running && deviceAuthorized
    }
    
    // MARK: - Initializers
    
    init(previewView: UIView) {
        self.previewView = previewView
        super.init()
    }
    
    // MARK: - NSKeyValueObserving
    
    class func keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized() -> Set<String> {
        return Set(["session.running", "deviceAuthorized"])
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &CapturingStillImageContext {
            let capturingStillImage = change[NSKeyValueChangeNewKey]?.boolValue
            
            if let isCapturingStillImage = capturingStillImage where isCapturingStillImage {
                self.delegate?.cameraControllerDidStartStillImageCapture?(self)
            }
        } else if context == &SessionRunningAndDeviceAuthorizedContext {
            let running = change[NSKeyValueChangeNewKey]?.boolValue
            
            if let isRunning = running {
                if isRunning {
                    self.delegate?.cameraControllerDidStartCamera?(self)
                } else {
                    self.delegate?.cameraControllerDidStopCamera?(self)
                }
            }
        } else if context == &FocusAndExposureContext {
            dispatch_async(dispatch_get_main_queue()) {
                self.updateFocusIndicatorLayer()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - SDK
    
    private func versionComponentsFromString(version: String) -> (majorVersion: Int, minorVersion: Int, patchVersion: Int)? {
        let versionComponents = version.componentsSeparatedByString(".")
        if count(versionComponents) == 3 {
            if let major = versionComponents[0].toInt(), minor = versionComponents[1].toInt(), patch = versionComponents[2].toInt() {
                return (major, minor, patch)
            }
        }
        
        return nil
    }
    
    private func checkSDKVersion() {
        let appIdentifier = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
        if let appIdentifier = appIdentifier, url = NSURL(string: "http://photoeditorsdk.com/version.json?type=ios&app=\(appIdentifier)") {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
                if let data = data {
                    let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject]
                    
                    if let json = json, version = json["version"] as? String, versionComponents = self.versionComponentsFromString(version) {
                        let remoteVersion = IMGLYSDKVersion(majorVersion: versionComponents.majorVersion, minorVersion: versionComponents.minorVersion, patchVersion: versionComponents.patchVersion)
                        
                        if CurrentSDKVersion < remoteVersion {
                            println("Your version of the img.ly SDK is outdated. You are using version \(CurrentSDKVersion), the latest available version is \(remoteVersion). Please consider updating.")
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: - Authorization
    
    public func checkDeviceAuthorizationStatus() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { granted in
            if granted {
                self.deviceAuthorized = true
            } else {
                self.delegate?.cameraControllerDidFailAuthorization?(self)
                self.deviceAuthorized = false
            }
        })
    }
    
    // MARK: - Camera
    
    /// Use this property to determine if more than one camera is available. Within the SDK this property is used to determine if the toggle button is visible.
    public var moreThanOneCameraPresent: Bool {
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        return videoDevices.count > 1
    }
    
    public func toggleCameraPosition() {
        if let device = videoDeviceInput?.device {
            let nextPosition: AVCaptureDevicePosition
            
            switch (device.position) {
            case .Front:
                nextPosition = .Back
            case .Back:
                nextPosition = .Front
            default:
                nextPosition = .Back
            }
            
            delegate?.cameraController?(self, willSwitchToCameraPosition: nextPosition)
            focusIndicatorLayer.hidden = true
            
            let sessionGroup = dispatch_group_create()
            
            if let videoPreviewView = videoPreviewView {
                // Hiding live preview
                videoPreviewView.hidden = true
                
                // Adding a simple snapshot and immediately showing it
                let snapshot = videoPreviewView.snapshotViewAfterScreenUpdates(false)
                snapshot.transform = videoPreviewView.transform
                snapshot.frame = videoPreviewView.frame
                previewView.addSubview(snapshot)
                
                // Creating a snapshot with a UIBlurEffect added
                let snapshotWithBlur = videoPreviewView.snapshotViewAfterScreenUpdates(false)
                snapshotWithBlur.transform = videoPreviewView.transform
                snapshotWithBlur.frame = videoPreviewView.frame
                
                let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
                visualEffectView.frame = snapshotWithBlur.bounds
                visualEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                snapshotWithBlur.addSubview(visualEffectView)
                
                // Transitioning between the regular snapshot and the blurred snapshot, this automatically removes `snapshot` and adds `snapshotWithBlur` to the view hierachy
                UIView.transitionFromView(snapshot, toView: snapshotWithBlur, duration: 0.4, options: .TransitionFlipFromLeft | .CurveEaseOut, completion: { _ in
                    // Wait for camera to toggle
                    dispatch_group_notify(sessionGroup, dispatch_get_main_queue()) {
                        // Cross fading between blur and live preview, this sets `snapshotWithBlur.hidden` to `true` and `videoPreviewView.hidden` to false
                        UIView.transitionFromView(snapshotWithBlur, toView: videoPreviewView, duration: 0.2, options: .TransitionCrossDissolve | .ShowHideTransitionViews, completion: { _ in
                            // Deleting the blurred snapshot
                            snapshotWithBlur.removeFromSuperview()
                        })
                    }
                })
            }
            
            dispatch_async(sessionQueue) {
                dispatch_group_enter(sessionGroup)
                self.session.beginConfiguration()
                self.session.removeInput(self.videoDeviceInput)
                
                self.removeObserversFromInputDevice()
                self.setupInputsForPreferredCameraPosition(nextPosition)
                self.addObserversToInputDevice()
                
                self.session.commitConfiguration()
                dispatch_group_leave(sessionGroup)
                
                self.delegate?.cameraController?(self, didSwitchToCameraPosition: nextPosition)
            }
        }
    }
    
    // MARK: - Flash
    
    /**
    Selects the next flash-mode. The order is Auto->On->Off.
    If the current device does not support auto-flash, this method
    just toggles between on and off.
    */
    public func selectNextFlashMode() {
        var nextFlashMode: AVCaptureFlashMode = .Off
        
        switch flashMode {
        case .Auto:
            if let device = videoDeviceInput?.device where device.isFlashModeSupported(.On) {
                nextFlashMode = .On
            }
        case .On:
            nextFlashMode = .Off
        case .Off:
            if let device = videoDeviceInput?.device {
                if device.isFlashModeSupported(.Auto) {
                    nextFlashMode = .Auto
                } else if device.isFlashModeSupported(.On) {
                    nextFlashMode = .On
                }
            }
        }
        
        flashMode = nextFlashMode
    }
    
    public private(set) var flashMode: AVCaptureFlashMode {
        get {
            if let device = self.videoDeviceInput?.device {
                return device.flashMode
            } else {
                return .Off
            }
        }
        
        set {
            dispatch_async(sessionQueue) {
                var error: NSError?
                self.session.beginConfiguration()
                
                if let device = self.videoDeviceInput?.device {
                    device.lockForConfiguration(&error)
                    device.flashMode = newValue
                    device.unlockForConfiguration()
                }
                
                self.session.commitConfiguration()
                
                if let error = error {
                    println("Error changing flash mode: \(error.description)")
                    return
                }
                
                self.delegate?.cameraController?(self, didChangeToFlashMode: newValue)
            }
        }
    }

    // MARK: - Focus
    
    private func setupFocusIndicator() {
        focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
        focusIndicatorLayer.borderWidth = 1
        focusIndicatorLayer.frame.size = CGSize(width: kIMGLYIndicatorSize, height: kIMGLYIndicatorSize)
        focusIndicatorLayer.hidden = true
        focusIndicatorLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        previewView.layer.addSublayer(focusIndicatorLayer)
        
        tapGestureRecognizer.addTarget(self, action: "tapped:")
        
        if let videoPreviewView = videoPreviewView {
            videoPreviewView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private func showFocusIndicatorLayerAtLocation(location: CGPoint) {
        focusIndicatorFadeOutTimer?.invalidate()
        focusIndicatorFadeOutTimer = nil
        focusIndicatorAnimating = false
        
        CATransaction.begin()
        focusIndicatorLayer.opacity = 1
        focusIndicatorLayer.hidden = false
        focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
        focusIndicatorLayer.frame.size = CGSize(width: kIMGLYIndicatorSize, height: kIMGLYIndicatorSize)
        focusIndicatorLayer.position = location
        focusIndicatorLayer.transform = CATransform3DIdentity
        focusIndicatorLayer.removeAllAnimations()
        CATransaction.commit()
        
        let resizeAnimation = CABasicAnimation(keyPath: "transform")
        resizeAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1))
        resizeAnimation.duration = 0.25
        focusIndicatorLayer.addAnimation(resizeAnimation, forKey: nil)
    }
    
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        if focusPointSupported || exposurePointSupported {
            if let videoPreviewView = videoPreviewView {
                let focusPointLocation = recognizer.locationInView(videoPreviewView)
                let scaleFactor = videoPreviewView.contentScaleFactor
                let videoFrame = CGRectMake(CGRectGetMinX(videoPreviewFrame) / scaleFactor, CGRectGetMinY(videoPreviewFrame) / scaleFactor, CGRectGetWidth(videoPreviewFrame) / scaleFactor, CGRectGetHeight(videoPreviewFrame) / scaleFactor)
                
                if CGRectContainsPoint(videoFrame, focusPointLocation) {
                    let focusIndicatorLocation = recognizer.locationInView(previewView)
                    showFocusIndicatorLayerAtLocation(focusIndicatorLocation)
                    
                    var pointOfInterest = CGPoint(x: focusPointLocation.x / CGRectGetWidth(videoFrame), y: focusPointLocation.y / CGRectGetHeight(videoFrame))
                    pointOfInterest.x = 1 - pointOfInterest.x
                    
                    if let device = videoDeviceInput?.device where device.position == .Front {
                        pointOfInterest.y = 1 - pointOfInterest.y
                    }
                    
                    focusWithMode(.AutoFocus, exposeWithMode: .AutoExpose, atDevicePoint: pointOfInterest, monitorSubjectAreaChange: true)
                }
            }
        }
    }
    
    private var focusPointSupported: Bool {
        if let device = videoDeviceInput?.device {
            return device.focusPointOfInterestSupported && device.isFocusModeSupported(.AutoFocus) && device.isFocusModeSupported(.ContinuousAutoFocus)
        }
        
        return false
    }
    
    private var exposurePointSupported: Bool {
        if let device = videoDeviceInput?.device {
            return device.exposurePointOfInterestSupported && device.isExposureModeSupported(.AutoExpose) && device.isExposureModeSupported(.ContinuousAutoExposure)
        }
        
        return false
    }
    
    private func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(sessionQueue) {
            if let device = self.videoDeviceInput?.device {
                var error: NSError?

                if device.lockForConfiguration(&error) {
                    if self.focusPointSupported {
                        device.focusMode = focusMode
                        device.focusPointOfInterest = point
                    }
                    
                    if self.exposurePointSupported {
                        device.exposureMode = exposureMode
                        device.exposurePointOfInterest = point
                    }
                    
                    device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                    device.unlockForConfiguration()
                } else {
                    println("Error in focusWithMode:exposeWithMode:atDevicePoint:monitorSubjectAreaChange: \(error?.description)")
                }
                
            }
        }
    }
    
    private func updateFocusIndicatorLayer() {
        if let device = videoDeviceInput?.device {
            if focusIndicatorLayer.hidden == false {
                if device.focusMode == .Locked && device.exposureMode == .Locked {
                    focusIndicatorLayer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
                }
            }
        }
    }
    
    @objc private func subjectAreaDidChange(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.disableFocusLockAnimated(true)
        }
    }
    
    public func disableFocusLockAnimated(animated: Bool) {
        if focusIndicatorAnimating {
            return
        }
        
        focusIndicatorAnimating = true
        focusIndicatorFadeOutTimer?.invalidate()
        
        if focusPointSupported || exposurePointSupported {
            focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: CGPoint(x: 0.5, y: 0.5), monitorSubjectAreaChange: false)
            
            if animated {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
                focusIndicatorLayer.frame.size = CGSize(width: kIMGLYIndicatorSize * 2, height: kIMGLYIndicatorSize * 2)
                focusIndicatorLayer.transform = CATransform3DIdentity
                focusIndicatorLayer.position = previewView.center
                
                CATransaction.commit()
                
                let resizeAnimation = CABasicAnimation(keyPath: "transform")
                resizeAnimation.duration = 0.25
                resizeAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1))
                resizeAnimation.delegate = IMGLYAnimationDelegate(block: { finished in
                    if finished {
                        self.focusIndicatorFadeOutTimer = NSTimer.after(0.85) { [unowned self] in
                            self.focusIndicatorLayer.opacity = 0
                            
                            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                            fadeAnimation.duration = 0.25
                            fadeAnimation.fromValue = 1
                            fadeAnimation.delegate = IMGLYAnimationDelegate(block: { finished in
                                if finished {
                                    CATransaction.begin()
                                    CATransaction.setDisableActions(true)
                                    self.focusIndicatorLayer.hidden = true
                                    self.focusIndicatorLayer.opacity = 1
                                    self.focusIndicatorLayer.frame.size = CGSize(width: kIMGLYIndicatorSize, height: kIMGLYIndicatorSize)
                                    CATransaction.commit()
                                    self.focusIndicatorAnimating = false
                                }
                            })
                            
                            self.focusIndicatorLayer.addAnimation(fadeAnimation, forKey: nil)
                        }
                    }
                })
                
                focusIndicatorLayer.addAnimation(resizeAnimation, forKey: nil)
            } else {
                focusIndicatorLayer.hidden = true
                focusIndicatorAnimating = false
            }
        } else {
            focusIndicatorLayer.hidden = true
            focusIndicatorAnimating = false
        }
    }
    
    // MARK: - Capture Session
    
    /**
    Initializes the camera and has to be called before calling `startCamera()` / `stopCamera()`
    */
    public func setup() {
        if setupComplete {
            return
        }
        
        checkSDKVersion()
        checkDeviceAuthorizationStatus()
        
        glContext = EAGLContext(API: .OpenGLES2)
        videoPreviewView = GLKView(frame: CGRectZero, context: glContext)
        videoPreviewView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        videoPreviewView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        videoPreviewView!.frame = previewView.bounds
        
        previewView.addSubview(videoPreviewView!)
        previewView.sendSubviewToBack(videoPreviewView!)
        
        ciContext = CIContext(EAGLContext: glContext)
        videoPreviewView!.bindDrawable()
        
        setupWithPreferredCameraPosition(.Back) {
            if let device = self.videoDeviceInput?.device {
                if device.isFlashModeSupported(.Auto) {
                    self.flashMode = .Auto
                }
            }
            
            self.delegate?.cameraControllerDidCompleteSetup?(self)
        }
        
        setupFocusIndicator()
        
        setupComplete = true
    }
    
    private func setupWithPreferredCameraPosition(cameraPosition: AVCaptureDevicePosition, completion: (() -> (Void))?) {
        dispatch_async(sessionQueue) {
            if self.session.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
                self.session.sessionPreset = AVCaptureSessionPresetPhoto
            }
            
            self.setupInputsForPreferredCameraPosition(cameraPosition)
            self.setupOutputs()
            
            completion?()
        }
    }
    
    private func setupInputsForPreferredCameraPosition(cameraPosition: AVCaptureDevicePosition) {
        var error: NSError?
        
        let videoDevice = IMGLYCameraController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: cameraPosition)
        let videoDeviceInput = AVCaptureDeviceInput(device: videoDevice, error: &error)
        
        if let error = error {
            println("Error in setupInputsForPreferredCameraPosition: \(error.description)")
        }
        
        if self.session.canAddInput(videoDeviceInput) {
            self.session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            dispatch_async(dispatch_get_main_queue()) {
                if let videoPreviewView = self.videoPreviewView, device = videoDevice {
                    if device.position == .Front {
                        // front camera is mirrored so we need to transform the preview view
                        videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                        videoPreviewView.transform = CGAffineTransformScale(videoPreviewView.transform, 1, -1)
                    } else {
                        videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                    }
                }
            }
        }
    }
    
    private func setupOutputs() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: self.sampleBufferQueue)
        if self.session.canAddOutput(videoDataOutput) {
            self.session.addOutput(videoDataOutput)
            self.videoDataOutput = videoDataOutput
        }
        
        let stillImageOutput = AVCaptureStillImageOutput()
        if self.session.canAddOutput(stillImageOutput) {
            self.session.addOutput(stillImageOutput)
            self.stillImageOutput = stillImageOutput
        }
    }

    /**
    Starts the camera preview.
    */
    public func startCamera() {
        assert(setupComplete, "setup() needs to be called before calling startCamera()")
        
        if session.running {
            return
        }
        
        startCameraWithCompletion(nil)
        
        // Used to determine device orientation even if orientation lock is active
        motionManager.startAccelerometerUpdatesToQueue(motionManagerQueue, withHandler: { accelerometerData, _ in
            if abs(accelerometerData.acceleration.y) < abs(accelerometerData.acceleration.x) {
                if accelerometerData.acceleration.x > 0 {
                    self.captureVideoOrientation = .LandscapeLeft
                } else {
                    self.captureVideoOrientation = .LandscapeRight
                }
            } else {
                if accelerometerData.acceleration.y > 0 {
                    self.captureVideoOrientation = .PortraitUpsideDown
                } else {
                    self.captureVideoOrientation = .Portrait
                }
            }
        })
    }
    
    private func startCameraWithCompletion(completion: (() -> (Void))?) {
        dispatch_async(sessionQueue) {
            self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: .Old | .New, context: &SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", options: .Old | .New, context: &CapturingStillImageContext)
            
            self.addObserversToInputDevice()
            
            self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil, usingBlock: { [unowned self] _ in
                dispatch_async(self.sessionQueue) {
                    self.session.startRunning()
                }
                })
            
            self.session.startRunning()
            completion?()
        }
    }
    
    private func addObserversToInputDevice() {
        if let device = self.videoDeviceInput?.device {
            device.addObserver(self, forKeyPath: "focusMode", options: .Old | .New, context: &FocusAndExposureContext)
            device.addObserver(self, forKeyPath: "exposureMode", options: .Old | .New, context: &FocusAndExposureContext)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)
    }
    
    private func removeObserversFromInputDevice() {
        if let device = self.videoDeviceInput?.device {
            device.removeObserver(self, forKeyPath: "focusMode", context: &FocusAndExposureContext)
            device.removeObserver(self, forKeyPath: "exposureMode", context: &FocusAndExposureContext)
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput?.device)
    }
    
    /**
    Stops the camera preview.
    */
    public func stopCamera() {
        assert(setupComplete, "setup() needs to be called before calling stopCamera()")
        
        if !session.running {
            return
        }
        
        stopCameraWithCompletion(nil)
        motionManager.stopAccelerometerUpdates()
    }
    
    private func stopCameraWithCompletion(completion: (() -> (Void))?) {
        dispatch_async(sessionQueue) {
            self.session.stopRunning()
            
            self.removeObserversFromInputDevice()
            
            if let runtimeErrorHandlingObserver = self.runtimeErrorHandlingObserver {
                NSNotificationCenter.defaultCenter().removeObserver(runtimeErrorHandlingObserver)
            }
            
            self.removeObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", context: &SessionRunningAndDeviceAuthorizedContext)
            self.removeObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", context: &CapturingStillImageContext)
            completion?()
        }
    }
    
    /// Check if the current device has a flash.
    public var flashAvailable: Bool {
        if let device = self.videoDeviceInput?.device {
            return device.flashAvailable
        }
        
        return false
    }
    
    // MARK: - Still Image Capture
    
    /**
    Takes a photo and hands it over to the completion block.
    
    :param: completion A completion block that has an image and an error as parameters.
    If the image was taken sucessfully the error is nil.
    */
    public func takePhoto(completion: IMGLYTakePhotoBlock) {
        if let stillImageOutput = self.stillImageOutput {
            dispatch_async(sessionQueue) {
                let connection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
                
                // Update the orientation on the still image output video connection before capturing.
                if let captureVideoOrientation = self.captureVideoOrientation {
                    connection.videoOrientation = captureVideoOrientation
                }
                
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection) {
                    (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
                    
                    if let imageDataSampleBuffer = imageDataSampleBuffer {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let image = UIImage(data: imageData)
                        
                        completion(image, nil)
                    } else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType) as! [AVCaptureDevice]
        var captureDevice = devices.first
        
        for device in devices {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        
        return captureDevice
    }
    
}

extension IMGLYCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        let mediaType = CMFormatDescriptionGetMediaType(formatDescription)
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let sourceImage = CIImage(CVPixelBuffer: imageBuffer as CVPixelBufferRef, options: nil)
        
        let filteredImage: CIImage?
        
        if effectFilter is IMGLYNoneFilter {
            filteredImage = sourceImage
        } else {
            filteredImage = IMGLYPhotoProcessor.processWithCIImage(sourceImage, filters: [effectFilter])
        }
        
        let sourceExtent = sourceImage.extent()
        
        if let videoPreviewView = videoPreviewView {
            let targetRect = CGRect(x: 0, y: 0, width: videoPreviewView.drawableWidth, height: videoPreviewView.drawableHeight)
            
            videoPreviewFrame = sourceExtent
            videoPreviewFrame.fittedIntoTargetRect(targetRect, withContentMode: .ScaleAspectFit)
            
            if glContext != EAGLContext.currentContext() {
                EAGLContext.setCurrentContext(glContext)
            }
            
            videoPreviewView.bindDrawable()
            
            glClearColor(0, 0, 0, 1.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            
            if let filteredImage = filteredImage {
                ciContext?.drawImage(filteredImage, inRect: videoPreviewFrame, fromRect: sourceExtent)
            }
            
            videoPreviewView.display()
        }
    }
}

extension CGRect {
    mutating func fittedIntoTargetRect(targetRect: CGRect, withContentMode contentMode: UIViewContentMode) {
        if !(contentMode == .ScaleAspectFit || contentMode == .ScaleAspectFill) {
            // Not implemented
            return
        }
        
        var scale = targetRect.width / self.width
        
        if contentMode == .ScaleAspectFit {
            if self.height * scale > targetRect.height {
                scale = targetRect.height / self.height
            }
        } else if contentMode == .ScaleAspectFill {
            if self.height * scale < targetRect.height {
                scale = targetRect.height / self.height
            }
        }
        
        let scaledWidth = self.width * scale
        let scaledHeight = self.height * scale
        let scaledX = targetRect.width / 2 - scaledWidth / 2
        let scaledY = targetRect.height / 2 - scaledHeight / 2
        
        self.origin.x = scaledX
        self.origin.y = scaledY
        self.size.width = scaledWidth
        self.size.height = scaledHeight
    }
}
