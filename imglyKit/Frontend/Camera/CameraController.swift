//
//  CameraController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import GLKit

@objc public enum CameraControllerError: Int, ErrorType {
    case MultipleCallsToSetup
    case UnableToInitializeCaptureDevice
}

private var cameraControllerContext = 0

@objc(IMGLYCameraController) public class CameraController: NSObject {

    // MARK: - Properties

    private let session = AVCaptureSession()
    private let sessionQueue = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL)
    private let sampleBufferQueue = dispatch_queue_create("sample_buffer_queue", DISPATCH_QUEUE_SERIAL)

    private var videoDeviceInput: AVCaptureDeviceInput?
    private let videoDataOutput = AVCaptureVideoDataOutput()

    private let glContext: EAGLContext
    public let videoPreviewView: GLKView

    private var setupComplete = false

    public var currentRecordingMode: RecordingMode {
        if session.sessionPreset == AVCaptureSessionPresetPhoto {
            return .Photo
        } else {
            return .Video
        }
    }

    // Handlers

    /// Called when the list of available recording modes was changed.
    public var availableRecordingModesChangedHandler: (() -> Void)? {
        didSet {
            // Call immediately for initial value
            availableRecordingModesChangedHandler?()
        }
    }

    /// Called when the list of available camera positions was changed.
    public var availableCameraPositionsChangedHandler: (() -> Void)? {
        didSet {
            // Call immediately for initial value
            availableCameraPositionsChangedHandler?()
        }
    }

    /// Called when any aspect of the flash changes.
    /// `hasFlash` is `true` if the current camera has a flash. `flashMode` represents the currently
    /// active flash mode. `flashAvailable` is `true` if the flash is available for use.
    public var flashChangedHandler: ((hasFlash: Bool, flashMode: AVCaptureFlashMode, flashAvailable: Bool) -> Void)?

    /// Called when any aspect of the torch changes.
    /// `hasTorch` is `true` if the current camera has a torch. `torchMMode` represents the currently
    /// active torch mode. `torchAvailable` is `true` if the torch is available for use.
    public var torchChangedHandler: ((hasTorch: Bool, torchMode: AVCaptureTorchMode, torchAvailable: Bool) -> Void)?

    // Options

    /// An array of recording modes (e.g. `.Photo`, `.Video`) that you want to support. Passing an empty
    /// array to this property is ignored. Defaults to all recording modes. Duplicate values result in
    /// undefined behaviour.
    public var recordingModes: [RecordingMode] = [.Photo, .Video] {
        didSet {
            // Require at least one `RecordingMode`
            if recordingModes.count == 0 {
                recordingModes = oldValue
            }

            if oldValue != recordingModes {
                // TODO: Stop recording if needed

                if !recordingModes.contains(currentRecordingMode) {
                    dispatch_async(sessionQueue) {
                        self.session.beginConfiguration()
                        self.changeSessionPreset(self.recordingModes[0].sessionPreset)
                        self.session.commitConfiguration()
                    }
                }

                availableRecordingModesChangedHandler?()
            }
        }
    }

    /// An array of `RecordingMode` raw values wrapped in `NSNumber`s.
    /// Setting this property overrides any previously set values in
    /// `recordingModes` with the corresponding unwrapped values.
    public var recordingModesAsNSNumbers: [NSNumber] {
        get {
            return recordingModes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            recordingModes = newValue.flatMap { RecordingMode(rawValue: $0.integerValue) }
        }
    }

    /// An array of camera positions (e.g. `.Front`, `.Back`) that you want to support. Setting
    /// this property automatically checks if the device supports all camera positions and updates
    /// the property accordingly if it does not. Passing an empty array to this property is ignored.
    /// Defaults to all available camera positions. Duplicate values result in undefined behaviour.
    public var cameraPositions: [AVCaptureDevicePosition] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).flatMap {
        ($0 as? AVCaptureDevice)?.position
        } {
        didSet {
            // Require at least one `AVCaptureDevicePosition`
            if cameraPositions.count == 0 {
                cameraPositions = oldValue
            }

            // Only set `AVCaptureDevicePosition`s which are actually supported by the device
            if oldValue != cameraPositions {
                let availableCameraPositions = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).flatMap {
                    ($0 as? AVCaptureDevice)?.position
                }

                cameraPositions = cameraPositions.filter { availableCameraPositions.contains($0) }
                availableCameraPositionsChangedHandler?()

                // Update current camera position if needed
                if let currentCameraPosition = videoDeviceInput?.device.position where setupComplete && !cameraPositions.contains(currentCameraPosition) {
                    switchToCameraAtPosition(nextCameraPositionForCurrentPosition(currentCameraPosition))
                }
            }
        }
    }

    /// An array of `AVCaptureDevicePosition` raw values wrapped in `NSNumber`s.
    /// Setting this property overrides any previously set values in
    /// `cameraPositions` with the corresponding unwrapped values.
    public var cameraPositionsAsNSNumbers: [NSNumber] {
        get {
            return cameraPositions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            cameraPositions = newValue.flatMap { AVCaptureDevicePosition(rawValue: $0.integerValue) }
        }
    }

    /// An array of flash modes (e.g. `.Auto`, `.On`, `.Off`) that you want to support. Passing an empty
    /// array to this property is ignored. Often not all modes are supported by each camera on a
    /// device, in which case only the supported flash modes are used.
    /// Defaults to all flash modes. Duplicate values result in undefined behaviour.
    public var flashModes: [AVCaptureFlashMode] = [.Auto, .On, .Off] {
        didSet {
            // Require at least one `AVCaptureFlashMode`
            if flashModes.count == 0 {
                flashModes = oldValue
            }

            if oldValue != flashModes {
                flashController?.flashModes = flashModes
            }
        }
    }

    /// An array of `AVCaptureFlashMode` raw values wrapped in `NSNumber`s.
    /// Setting this property overrides any previously set values in
    /// `flashModes` with the corresponding unwrapped values.
    public var flashModesAsNSNumbers: [NSNumber] {
        get {
            return flashModes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            flashModes = newValue.flatMap { AVCaptureFlashMode(rawValue: $0.integerValue) }
        }
    }

    /// An array of torch modes (e.g. `.Auto`, `.On`, `.Off`) that you want to support. Passing an empty
    /// array to this property is ignored. Often not all modes are supported by each camera on a
    /// device, in which case only the supported torch modes are used.
    /// Defaults to all torch modes. Duplicate values result in undefined behaviour.
    public var torchModes: [AVCaptureTorchMode] = [.Auto, .On, .Off] {
        didSet {
            // Require at least one `AVCaptureTorchMode`
            if torchModes.count == 0 {
                torchModes = oldValue
            }

            if oldValue != torchModes {
                torchController?.torchModes = torchModes
            }
        }
    }

    /// An array of `AVCaptureTorchMode` raw values wrapped in `NSNumber`s.
    /// Setting this property overrides any previously set values in
    /// `torchModes` with the corresponding unwrapped values.
    public var torchModesAsNSNumbers: [NSNumber] {
        get {
            return torchModes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            torchModes = newValue.flatMap { AVCaptureTorchMode(rawValue: $0.integerValue) }
        }
    }

    private let sampleBufferController: SampleBufferController
    private let deviceOrientationController = DeviceOrientationController()
    private var flashController: FlashController?
    private var torchController: TorchController?

    // MARK: - Initializer

    public override init() {
        guard let glContext = EAGLContext(API: .OpenGLES2) else {
            fatalError("Unable to create EAGLContext")
        }

        self.glContext = glContext

        videoPreviewView = GLKView(frame: CGRectZero, context: glContext)
        videoPreviewView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // Rotate to match images coming from the camera
        videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))

        sampleBufferController = SampleBufferController(
            videoPreviewView: videoPreviewView
        )

        super.init()
    }

    // MARK: - Observers

    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "sessionRuntimeError:",
            name: AVCaptureSessionRuntimeErrorNotification,
            object: session
        )

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "sessionWasInterrupted:",
            name: AVCaptureSessionWasInterruptedNotification,
            object: session
        )

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "sessionInterruptionEnded:",
            name: AVCaptureSessionInterruptionEndedNotification,
            object: session)
    }

    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc private func sessionRuntimeError(notification: NSNotification) {
        // TODO
    }

    @objc private func sessionWasInterrupted(notification: NSNotification) {
        // TODO
    }

    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        // TODO
    }

    private func addFlashObserversForController(flashController: FlashController) {
        flashController.addObserver(self, forKeyPath: "hasFlash", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        flashController.addObserver(self, forKeyPath: "flashMode", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        flashController.addObserver(self, forKeyPath: "flashAvailable", options: [.New, .Old, .Initial], context: &cameraControllerContext)
    }

    private func addTorchObserversForController(torchController: TorchController) {
        torchController.addObserver(self, forKeyPath: "hasTorch", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        torchController.addObserver(self, forKeyPath: "torchMode", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        torchController.addObserver(self, forKeyPath: "torchAvailable", options: [.New, .Old, .Initial], context: &cameraControllerContext)
    }

    private func removeFlashObserversForController(flashController: FlashController) {
        flashController.removeObserver(self, forKeyPath: "hasFlash", context: &cameraControllerContext)
        flashController.removeObserver(self, forKeyPath: "flashMode", context: &cameraControllerContext)
        flashController.removeObserver(self, forKeyPath: "flashAvailable", context: &cameraControllerContext)
    }

    private func removeTorchObserversForController(torchController: TorchController) {
        torchController.removeObserver(self, forKeyPath: "hasTorch", context: &cameraControllerContext)
        torchController.removeObserver(self, forKeyPath: "torchMode", context: &cameraControllerContext)
        torchController.removeObserver(self, forKeyPath: "torchAvailable", context: &cameraControllerContext)
    }

    private func addFlashAndTorchObservers() {
        if let flashController = self.flashController {
            self.addFlashObserversForController(flashController)
        }

        if let torchController = self.torchController {
            self.addTorchObserversForController(torchController)
        }
    }

    private func removeFlashAndTorchObservers() {
        if let flashController = self.flashController {
            self.removeFlashObserversForController(flashController)
        }

        if let torchController = self.torchController {
            self.removeTorchObserversForController(torchController)
        }
    }

    // MARK: - Setup

    /**
    Initializes the camera. This method __must__ be called before calling `startCamera()`.
    Any handlers that will be used should be set before calling this method, so that they are called
    with their initial values.

    - throws: A `CameraControllerError` or an `NSError` if setup fails.
    */
    public func setup() throws {
        try setupWithCompletion(nil)
    }

    /**
     Same as `setup()` but with an optional completion handler. The completion handler is always invoked
     on the main thread.

     - parameter completion: A block to be executed when the camera has finished initialization.

     - throws: A `CameraControllerError` or an `NSError` if setup fails.
     */
    public func setupWithCompletion(completion: (() -> Void)?) throws {
        if setupComplete {
            throw CameraControllerError.MultipleCallsToSetup
        }

        guard let videoDevice = AVCaptureDevice.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: cameraPositions[0]) else {
            throw CameraControllerError.UnableToInitializeCaptureDevice
        }

        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        self.videoDeviceInput = videoDeviceInput

        flashController = FlashController(flashModes: flashModes, session: session, videoDeviceInput: videoDeviceInput, sessionQueue: sessionQueue)
        torchController = TorchController(torchModes: torchModes, session: session, videoDeviceInput: videoDeviceInput, sessionQueue: sessionQueue)
        addFlashAndTorchObservers()

        dispatch_async(sessionQueue) {
            self.session.beginConfiguration()
            self.addVideoDeviceInput(videoDeviceInput)
            self.addVideoDataOutput(self.videoDataOutput)
            self.changeSessionPreset(self.recordingModes[0].sessionPreset)
            self.session.commitConfiguration()

            dispatch_async(dispatch_get_main_queue()) {
                self.transformVideoPreviewToMatchDevicePosition(videoDeviceInput.device.position)
                completion?()
            }
        }

        setupComplete = true
    }

    // MARK: - View Transformation

    private func transformVideoPreviewToMatchDevicePosition(position: AVCaptureDevicePosition) {
        switch position {
        case .Front:
            // Front camera is mirrored so we need to transform the preview view
            self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            self.videoPreviewView.transform = CGAffineTransformScale(self.videoPreviewView.transform, 1, -1)
        case .Back:
            self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        case .Unspecified:
            break
        }
    }

    // MARK: - Session Configuration

    private func addVideoDeviceInput(videoDeviceInput: AVCaptureDeviceInput) {
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        }
    }

    private func addVideoDataOutput(videoDataOutput: AVCaptureVideoDataOutput) {
        if session.canAddOutput(videoDataOutput) {
            videoDataOutput.setSampleBufferDelegate(sampleBufferController, queue: sampleBufferQueue)
            session.addOutput(videoDataOutput)
        }
    }

    private func changeSessionPreset(sessionPreset: String) {
        if session.canSetSessionPreset(sessionPreset) {
            session.sessionPreset = sessionPreset
        }
    }

    // MARK: - Starting / Stopping

    /**
    Starts the camera. `setup()` __must__ be called before calling this method, otherwise this method does
    nothing. You should also add the `videoPreviewView` to your view hierachy to see the camera output.
    */
    public func startCamera() {
        if !setupComplete {
            print("You must call setup() before calling startCamera()")
            return
        }

        deviceOrientationController.start()
        videoPreviewView.bindDrawable()

        dispatch_async(sessionQueue) {
            self.addObservers()
            self.session.startRunning()
        }
    }

    /**
    Stops the camera.
    */
    public func stopCamera() {
        deviceOrientationController.stop()

        dispatch_async(sessionQueue) {
            self.session.stopRunning()
            self.removeObservers()
        }
    }

    // MARK: - Camera Switching

    private func nextCameraPositionForCurrentPosition(position: AVCaptureDevicePosition?) -> AVCaptureDevicePosition {
        let nextPosition: AVCaptureDevicePosition

        if let currentPosition = position {
            switch currentPosition {
            case .Front, .Unspecified where cameraPositions.contains(.Back):
                nextPosition = .Back
            case .Back where cameraPositions.contains(.Front):
                nextPosition = .Front
            default:
                nextPosition = currentPosition
            }
        } else {
            nextPosition = cameraPositions[0]
        }

        return nextPosition
    }

    /**
     Switches the camera to the other position (e.g. `.Back` -> `.Front` and `.Front` -> `.Back`)
     */
    public func toggleCameraPosition() {
        switchToCameraAtPosition(nextCameraPositionForCurrentPosition(videoDeviceInput?.device.position))
    }

    /**
    Switches the camera to the desired position (if available).

    - parameter position: The position to switch to.
    */
    public func switchToCameraAtPosition(position: AVCaptureDevicePosition) {
        if !setupComplete {
            print("You must call setup() before calling switchToCameraAtPosition(:)")
            return
        }

        dispatch_async(sessionQueue) {
            self.session.beginConfiguration()

            if let input = self.videoDeviceInput {
                self.session.removeInput(input)
            }

            self.removeFlashAndTorchObservers()

            if let device = AVCaptureDevice.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: position), input = try? AVCaptureDeviceInput(device: device) {
                self.videoDeviceInput = input
                self.addVideoDeviceInput(input)

                self.flashController = FlashController(flashModes: self.flashModes, session: self.session, videoDeviceInput: input, sessionQueue: self.sessionQueue)
                self.torchController = TorchController(torchModes: self.torchModes, session: self.session, videoDeviceInput: input, sessionQueue: self.sessionQueue)

                self.addFlashAndTorchObservers()
            }

            self.session.commitConfiguration()

            if let device = self.videoDeviceInput?.device {
                dispatch_async(dispatch_get_main_queue()) {
                    self.transformVideoPreviewToMatchDevicePosition(device.position)
                }
            }
        }
    }

    // MARK: - LED

    /**
    Selects the next flash mode. The order is taken from `flashModes`.
    If the current device does not support a flash mode, the next flash mode that is supported is used or `.Off`.
    */
    public func selectNextFlashMode() {
        flashController?.selectNextFlashMode()
    }

    /**
     Selects the next torch mode. The order is taken from `torchModes`.
     If the current device does not support a torch mode, the next flash mode that is supported is used or `.Off`.
     */
    public func selectNextTorchMode() {
        torchController?.selectNextTorchMode()
    }

    // MARK: - KVO

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath where context == &cameraControllerContext {
            switch keyPath {
            case "hasFlash", "flashMode", "flashAvailable":
                dispatch_async(dispatch_get_main_queue()) {
                    self.flashChangedHandler?(
                        hasFlash: self.flashController?.hasFlash ?? false,
                        flashMode: self.flashController?.flashMode ?? .Off,
                        flashAvailable: self.flashController?.flashAvailable ?? false
                    )
                }
            case "hasTorch", "torchMode", "torchAvailable":
                dispatch_async(dispatch_get_main_queue()) {
                    self.torchChangedHandler?(
                        hasTorch: self.torchController?.hasTorch ?? false,
                        torchMode: self.torchController?.torchMode ?? .Off,
                        torchAvailable: self.torchController?.torchAvailable ?? false
                    )
                }
            default:
                break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}
