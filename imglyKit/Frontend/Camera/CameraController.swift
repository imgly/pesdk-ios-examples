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

/**
 This enum holds types of errors that occur while using the `CameraController`.

 - MultipleCallsToSetup:            Indicates that setup is called multiple times.
 - UnableToInitializeCaptureDevice: Indicates that the capture device can't be initialized.
 */
@objc public enum CameraControllerError: Int, ErrorType {
    /// :nodoc:
    case MultipleCallsToSetup
    /// :nodoc:
    case UnableToInitializeCaptureDevice
}

private var cameraControllerContext = 0

/**
 The `CameraController` class provides functions for serveral camera related tasks,
 including setup, flash control, and such.
 */
@objc(IMGLYCameraController) public class CameraController: NSObject {

    // MARK: - Properties

    private dynamic let session = AVCaptureSession()
    private let sessionQueue = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL)
    private let sampleBufferQueue = dispatch_queue_create("sample_buffer_queue", DISPATCH_QUEUE_SERIAL)

    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let audioDataOutput = AVCaptureAudioDataOutput()
    private let stillImageOutput = AVCaptureStillImageOutput()

    private let glContext: EAGLContext

    /// An instance of a `GLKView` that is used to present the preview.
    public let videoPreviewView: GLKView

    private var setupComplete = false

    /// The currently active recording mode (i.e. `.Photo` or `.Video`). Setting this property before
    /// calling `setupWithInitialRecordingMode(:)` is ignored. The setter asynchronously updates the
    /// session, so the getter might not immediately represent the new value. You can observe changes
    /// to the value of this property using key-value observing.
    public var recordingMode: RecordingMode {
        get {
            if session.sessionPreset == AVCaptureSessionPresetPhoto {
                return .Photo
            } else {
                return .Video
            }
        }

        set {
            if !setupComplete || recordingMode == newValue {
                return
            }

            dispatch_async(sessionQueue) {
                self.removeLightObserver()
                self.session.beginConfiguration()
                self.changeSessionPreset(newValue.sessionPreset)
                if newValue.sessionPreset != AVCaptureSessionPresetPhoto {
                    self.addAudioInput()
                    self.createVideoController()
                } else {
                    self.videoController = nil
                }

                self.session.commitConfiguration()

                // Change LightController (from Flash to Torch or vice-versa)
                if let videoDeviceInput = self.videoDeviceInput {
                    self.createLightControllerForSession(self.session, videoDeviceInput: videoDeviceInput, sessionQueue: self.sessionQueue)
                    self.addLightObservers()
                }
            }
        }
    }

    // Handlers

    /// Called when the `running` state of the camera changes.
    public var runningStateChangedHandler: ((running: Bool) -> Void)?

    /// Called when the camera position changes.
    public var cameraPositionChangedHandler: ((previousPosition: AVCaptureDevicePosition, newPosition: AVCaptureDevicePosition) -> Void)?

    /// Called when the recording mode changes.
    public var recordingModeChangedHandler: ((previousRecordingMode: RecordingMode?, newRecordingMode: RecordingMode) -> Void)?

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

    /// Called when a photo is currently being captured or done being captured.
    public var capturingStillImageHandler: ((capturing: Bool) -> Void)?

    /// Called when the session is interrupted or the interruption ended. This can happen when
    /// switching to a multi-app layout, introduced in iOS 9 for example.
    public var sessionInterruptionHandler: ((interrupted: Bool) -> Void)?

    /// Called when a runtime error occurs.
    public var sessionRuntimeErrorHandler: ((error: NSError) -> Void)?

    /// Called when the user did not grant authorization for the camera.
    public var authorizationFailedHandler: (() -> Void)?

    /// Called when video recording starts.
    public var videoRecordingStartedHandler: (() -> Void)?

    /// Called when video recording finishes.
    public var videoRecordingFinishedHandler: ((fileURL: NSURL) -> Void)?

    /// Called when video recording fails.
    public var videoRecordingFailedHandler: (() -> Void)?

    /// Called each second while a video recording is in progress.
    public var videoRecordingProgressHandler: ((seconds: Int) -> Void)?

    /// Called when the size of the preview image within the `videoPreviewView` changes
    public var previewFrameChangedHandler: ((previewFrame: CGRect) -> Void)?

    /// Called when the focus point changes.
    public var focusPointChangedHandler: ((point: CGPoint) -> Void)?

    /// Called when the focus mode changes.
    public var focusModeChangedHandler: ((focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode) -> Void)?

    /// Called when the focus gets disabled.
    public var focusDisabledHandler: (() -> Void)?

    // Options

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

            if let flashController = lightController as? FlashController where oldValue != flashModes {
                flashController.lightModes = flashModes.map { LightMode(flashMode: $0) }
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

            if let torchController = lightController as? TorchController where oldValue != torchModes {
                torchController.lightModes = torchModes.map { LightMode(torchMode: $0) }
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

    /// Set to `false` to disable locking focus when a user taps on the live preview. Default is `true`.
    public var tapToFocusEnabled = true {
        didSet {
            if oldValue != tapToFocusEnabled {
                if let videoDeviceInput = videoDeviceInput where tapToFocusEnabled {
                    createFocusControllerForVideoDeviceInput(videoDeviceInput)
                } else {
                    focusController = nil
                }
            }
        }
    }

    /// The effect filter that is applied to the live feed.
    public var effectFilter: EffectFilter {
        get {
            return sampleBufferController.effectFilter
        }

        set {
            sampleBufferController.effectFilter = newValue
        }
    }

    let deviceOrientationController = DeviceOrientationController()
    private let sampleBufferController: SampleBufferController
    private var lightController: LightControllable?
    private var videoController: VideoController? {
        didSet {
            sampleBufferController.videoController = videoController
        }
    }
    private var focusController: FocusController?

    // MARK: - Initializer

    /**
    :nodoc:
    */
    public override init() {
        guard let glContext = EAGLContext(API: .OpenGLES2) else {
            fatalError("Unable to create EAGLContext")
        }

        self.glContext = glContext

        videoPreviewView = GLKView(frame: CGRect.zero, context: glContext)
        videoPreviewView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // Rotate to match images coming from the camera
        videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))

        sampleBufferController = SampleBufferController(videoPreviewView: videoPreviewView)

        super.init()
    }

    // MARK: - Observers

    private func addSessionObservers() {
        session.addObserver(self, forKeyPath: "running", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        stillImageOutput.addObserver(self, forKeyPath: "capturingStillImage", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        addObserver(self, forKeyPath: "recordingMode", options: [.New, .Old, .Initial], context: &cameraControllerContext)

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

    private func removeSessionObservers() {
        session.removeObserver(self, forKeyPath: "running", context: &cameraControllerContext)
        removeObserver(self, forKeyPath: "recordingMode", context: &cameraControllerContext)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }

        self.sessionRuntimeErrorHandler?(error: error)
    }

    @objc private func sessionWasInterrupted(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.sessionInterruptionHandler?(interrupted: true)
        }
    }

    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.sessionInterruptionHandler?(interrupted: false)
        }
    }

    private func addLightObserversForController(lightController: LightControllable) {
        if let lightController = lightController as? NSObject {
            lightController.addObserver(self, forKeyPath: "hasLight", options: [.New, .Old, .Initial], context: &cameraControllerContext)
            lightController.addObserver(self, forKeyPath: "lightMode", options: [.New, .Old, .Initial], context: &cameraControllerContext)
            lightController.addObserver(self, forKeyPath: "lightAvailable", options: [.New, .Old, .Initial], context: &cameraControllerContext)
        }
    }

    private func removeLightObserversForController(lightController: LightControllable) {
        if let lightController = lightController as? NSObject {
            lightController.removeObserver(self, forKeyPath: "hasLight", context: &cameraControllerContext)
            lightController.removeObserver(self, forKeyPath: "lightMode", context: &cameraControllerContext)
            lightController.removeObserver(self, forKeyPath: "lightAvailable", context: &cameraControllerContext)
        }
    }

    private func addLightObservers() {
        if let lightController = self.lightController {
            self.addLightObserversForController(lightController)
        }
    }

    private func removeLightObserver() {
        if let lightController = self.lightController {
            self.removeLightObserversForController(lightController)
        }
    }

    // MARK: - Setup

    /**
    Initializes the camera. This method __must__ be called before calling `startCamera()`.
    Any handlers that will be used should be set before calling this method, so that they are called
    with their initial values.

    - parameter recordingMode: The initial recording mode (e.g. `.Photo` or `.Video`) to use when
    initializing the camera.

    - throws: A `CameraControllerError` or an `NSError` if setup fails.
    */
    public func setupWithInitialRecordingMode(recordingMode: RecordingMode) throws {
        try setupWithInitialRecordingMode(recordingMode, completion: nil)
    }

    /**
     Same as `setupWithInitialRecordingMode(:)` but with an optional completion handler. The completion handler is always invoked
     on the main thread.

     - parameter recordingMode: The initial recording mode (e.g. `.Photo` or `.Video`) to use when
     initializing the camera.
     - parameter completion: A block to be executed when the camera has finished initialization.

     - throws: A `CameraControllerError` or an `NSError` if setup fails.
     */
    public func setupWithInitialRecordingMode(recordingMode: RecordingMode, completion: (() -> Void)?) throws {
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Denied {
            dispatch_async(dispatch_get_main_queue()) {
                self.authorizationFailedHandler?()
            }
        }

        if setupComplete {
            throw CameraControllerError.MultipleCallsToSetup
        }

        guard let
            cameraPosition = cameraPositions.first,
            videoDevice = AVCaptureDevice.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: cameraPosition) else {
            throw CameraControllerError.UnableToInitializeCaptureDevice
        }

        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        self.videoDeviceInput = videoDeviceInput

        videoDataOutput.setSampleBufferDelegate(self.sampleBufferController, queue: self.sampleBufferQueue)
        audioDataOutput.setSampleBufferDelegate(self.sampleBufferController, queue: self.sampleBufferQueue)

        sampleBufferController.previewFrameChangedHandler = { [weak self] previewFrame in
            dispatch_async(dispatch_get_main_queue()) {
                self?.focusController?.videoPreviewFrame = previewFrame
                self?.previewFrameChangedHandler?(previewFrame: previewFrame)
            }
        }

        if tapToFocusEnabled {
            createFocusControllerForVideoDeviceInput(videoDeviceInput)
        }

        dispatch_async(sessionQueue) {
            self.session.beginConfiguration()
            self.addDeviceInput(videoDeviceInput)
            self.addCaptureOutput(self.videoDataOutput)
            self.addCaptureOutput(self.audioDataOutput)
            self.addCaptureOutput(self.stillImageOutput)
            self.changeSessionPreset(recordingMode.sessionPreset)

            if recordingMode.sessionPreset != AVCaptureSessionPresetPhoto {
                self.addAudioInput()
                self.createVideoController()
            }

            self.session.commitConfiguration()

            dispatch_async(dispatch_get_main_queue()) {
                self.createLightControllerForSession(self.session, videoDeviceInput: videoDeviceInput, sessionQueue: self.sessionQueue)
                self.addLightObservers()
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

    private func addDeviceInput(deviceInput: AVCaptureDeviceInput) {
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
    }

    private func addCaptureOutput(captureOutput: AVCaptureOutput) {
        if session.canAddOutput(captureOutput) {
            session.addOutput(captureOutput)
        }
    }

    private func changeSessionPreset(sessionPreset: String) {
        if session.canSetSessionPreset(sessionPreset) {
            session.sessionPreset = sessionPreset
        }
    }

    private func addAudioInput() {
        if audioDeviceInput != nil {
            return
        }

        if let audioDevice = AVCaptureDevice.deviceWithMediaType(AVMediaTypeAudio),
            audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) {
                addDeviceInput(audioDeviceInput)
                self.audioDeviceInput = audioDeviceInput
        }
    }

    // MARK: - Starting / Stopping

    /**
    Starts the camera. `setupWithInitialRecordingMode(:)` __must__ be called before calling this method, otherwise this method does
    nothing. You should also add the `videoPreviewView` to your view hierachy to see the camera output.
    */
    public func startCamera() {
        if !setupComplete {
            print("You must call setupWithInitialRecordingMode(:) before calling startCamera()")
            return
        }

        deviceOrientationController.start()
        videoPreviewView.bindDrawable()

        dispatch_async(sessionQueue) {
            self.addSessionObservers()
            self.session.startRunning()
        }
    }

    /**
    Stops the camera.
    */
    public func stopCamera() {
        if !setupComplete || !session.running {
            return
        }

        deviceOrientationController.stop()

        dispatch_async(sessionQueue) {
            self.session.stopRunning()
            self.removeSessionObservers()
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
            print("You must call setupWithInitialRecordingMode(:) before calling switchToCameraAtPosition(:)")
            return
        }

        dispatch_async(sessionQueue) {
            self.session.beginConfiguration()

            let previousPosition = self.videoDeviceInput?.device.position ?? .Unspecified
            if let input = self.videoDeviceInput {
                self.session.removeInput(input)
            }

            self.removeLightObserver()
            self.focusController = nil

            if let device = AVCaptureDevice.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: position), input = try? AVCaptureDeviceInput(device: device) {
                self.videoDeviceInput = input
                self.addDeviceInput(input)

                self.createLightControllerForSession(self.session, videoDeviceInput: input, sessionQueue: self.sessionQueue)
                self.addLightObservers()

                if self.tapToFocusEnabled {
                    self.createFocusControllerForVideoDeviceInput(input)
                }
            }

            self.session.commitConfiguration()

            if let device = self.videoDeviceInput?.device {
                dispatch_async(dispatch_get_main_queue()) {
                    self.transformVideoPreviewToMatchDevicePosition(device.position)
                    self.cameraPositionChangedHandler?(
                        previousPosition: previousPosition,
                        newPosition: device.position
                    )
                }
            }
        }
    }

    // MARK: - Photo

    /**
    Takes a photo and hands it over to the completion block. The completion block always runs on the main
    thread.

    - parameter completion: A completion block that has an image and an error as parameters.
    If the image was taken sucessfully the error is nil.
    */
    public func takePhoto(completion: (UIImage?, NSError?) -> Void) {
        if !setupComplete {
            return
        }

        dispatch_async(sessionQueue) {
            let connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)

            // Update the orientation on the still image output video connection before capturing.
            if let captureVideoOrientation = self.deviceOrientationController.captureVideoOrientation {
                connection.videoOrientation = captureVideoOrientation
            }

            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection) { imageDataSampleBuffer, error in
                if let imageDataSampleBuffer = imageDataSampleBuffer {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    let image = UIImage(data: imageData)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(image, nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil, error)
                    }
                }
            }
        }
    }

    // MARK: - Video

    private func createVideoController() {
        if videoController != nil {
            return
        }


        videoController = VideoController(videoOutputSettings: videoDataOutput.recommendedVideoSettingsForAssetWriterWithOutputFileType(AVFileTypeQuickTimeMovie) as? [String: AnyObject], audioOutputSettings: audioDataOutput.recommendedAudioSettingsForAssetWriterWithOutputFileType(AVFileTypeQuickTimeMovie) as? [String: AnyObject], sampleBufferQueue: sampleBufferQueue) { [weak self] started, failed, fileURL, timeRecorded in
            dispatch_async(dispatch_get_main_queue()) {
                if started {
                    self?.videoRecordingStartedHandler?()
                }

                if failed {
                    self?.videoRecordingFailedHandler?()
                }

                if let fileURL = fileURL {
                    self?.videoRecordingFinishedHandler?(fileURL: fileURL)
                }

                if let timeRecorded = timeRecorded {
                    self?.videoRecordingProgressHandler?(seconds: timeRecorded)
                }
            }
        }
    }

    /// Starts the video recording. This only works if `recordingMode` is set to .Video. You should
    /// set appropriate blocks for `videoRecordingStartedHandler`, `videoRecordingFailedHandler`,
    /// `videoRecordingFinishedHandler` and `videoRecordingProgressHandler`. The finished handler gets
    /// passed a `NSURL` to the path of the recorded video file. Please note that you are responsible
    /// for deleting that file when you no longer need it.
    public func startVideoRecording() {
        guard let videoDeviceInput = videoDeviceInput else {
            return
        }

        let recordAudio = audioDeviceInput != nil
        videoController?.startWritingWithVideoDimensions(sampleBufferController.currentVideoDimensions, orientation: deviceOrientationController.captureVideoOrientation, cameraPosition: videoDeviceInput.device.position, recordAudio: recordAudio)
    }

    /// Stops video recording. This only works if you previously started video recording.
    public func stopVideoRecording() {
        videoController?.stopWritingWithCompletionHandler(nil)
    }

    // MARK: - LED

    private func createLightControllerForSession(session: AVCaptureSession, videoDeviceInput: AVCaptureDeviceInput, sessionQueue: dispatch_queue_t) {
        if recordingMode.sessionPreset == AVCaptureSessionPresetPhoto {
            lightController = FlashController(flashModes: flashModes, session: session, videoDeviceInput: videoDeviceInput, sessionQueue: sessionQueue)
        } else {
            lightController = TorchController(torchModes: torchModes, session: session, videoDeviceInput: videoDeviceInput, sessionQueue: sessionQueue)
        }
    }

    /**
    Selects the next light mode. The order is taken from `flashModes` or `torchModes` depending on which is active.
    If the current device does not support a light mode, the next light mode that is supported is used or `.Off`.
    */
    public func selectNextLightMode() {
        lightController?.selectNextLightMode()
    }

    // MARK: - Focus

    private func createFocusControllerForVideoDeviceInput(videoDeviceInput: AVCaptureDeviceInput) {
        focusController = FocusController(videoDeviceInput: videoDeviceInput, videoPreviewView: videoPreviewView, videoPreviewFrame: sampleBufferController.currentPreviewFrame, sessionQueue: sessionQueue)
        focusController?.handler = { [weak self] point, mode, disabled in
            dispatch_async(dispatch_get_main_queue()) {
                if let point = point {
                    self?.focusPointChangedHandler?(point: point)
                }

                if let mode = mode {
                    self?.focusModeChangedHandler?(focusMode: mode.0, exposureMode: mode.1)
                }

                if disabled {
                    self?.focusDisabledHandler?()
                }
            }
        }
    }

    // MARK: - KVO

    @objc private class func keyPathsForValuesAffectingRecordingMode() -> Set<String> {
        return ["session.sessionPreset"]
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath where context == &cameraControllerContext {
            switch keyPath {
            case "hasLight", "lightMode", "lightAvailable":
                if object is FlashController {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.flashChangedHandler?(
                            hasFlash: self.lightController?.hasLight ?? false,
                            flashMode: AVCaptureFlashMode(lightMode: (self.lightController?.lightMode ?? .Off)),
                            flashAvailable: self.lightController?.lightAvailable ?? false
                        )
                    }
                } else if object is TorchController {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.torchChangedHandler?(
                            hasTorch: self.lightController?.hasLight ?? false,
                            torchMode: AVCaptureTorchMode(lightMode: (self.lightController?.lightMode ?? .Off)),
                            torchAvailable: self.lightController?.lightAvailable ?? false
                        )
                    }
                }
            case "recordingMode":
                guard let
                    newRecordingModeRaw = change?[NSKeyValueChangeNewKey] as? Int,
                    newRecordingMode = RecordingMode(rawValue: newRecordingModeRaw) else {
                    return
                }

                let previousRecordingMode: RecordingMode?
                if let previousRecordingModeRaw = change?[NSKeyValueChangeOldKey] as? Int {
                    previousRecordingMode = RecordingMode(rawValue: previousRecordingModeRaw)
                } else {
                    previousRecordingMode = nil
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.recordingModeChangedHandler?(
                        previousRecordingMode: previousRecordingMode,
                        newRecordingMode: newRecordingMode
                    )
                }
            case "capturingStillImage":
                guard let capturing = change?[NSKeyValueChangeNewKey] as? Bool else {
                    return
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.capturingStillImageHandler?(capturing: capturing)
                }
            case "running":
                guard let running = change?[NSKeyValueChangeNewKey] as? NSNumber else {
                    return
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.runningStateChangedHandler?(running: running.boolValue)
                }
            default:
                break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}
