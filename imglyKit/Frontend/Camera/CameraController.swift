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

    // Options

    /// An array of recording modes (e.g. .Photo, .Video) that you want to support. Passing an empty
    /// array to this property is ignored. Defaults to all recording modes. Duplicate values result in
    /// undefined behaviour.
    public var recordingModes: [RecordingMode] = [.Photo, .Video] {
        didSet {
            // Require at least one `RecordingMode`
            if recordingModes.count == 0 {
                recordingModes = oldValue
            }

            if oldValue != recordingModes {
                // TODO: Update current recording mode (and stop recording) if needed
            }
        }
    }

    /// An array of `RecordingMode` raw values wrapped in NSNumbers.
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

    /// An array of camera positions (e.g. .Front, .Back) that you want to support. Setting
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

                // TODO: Update current camera position if needed
            }
        }
    }

    /// An array of `AVCaptureDevicePosition` raw values wrapped in NSNumbers.
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

    /// An array of flash modes (e.g. .Auto, .On, .Off) that you want to support. Passing an empt
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

    /// An array of `AVCaptureFlashMode` raw values wrapped in NSNumbers.
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

    /// An array of torch modes (e.g. .Auto, .On, .Off) that you want to support. Passing an empty
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

    /// An array of `AVCaptureTorchMode` raw values wrapped in NSNumbers.
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

    // MARK: - Setup

    public func setup() throws {
        try setupWithCompletion(nil)
    }

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

    public func stopCamera() {
        deviceOrientationController.stop()

        dispatch_async(sessionQueue) {
            self.session.stopRunning()
            self.removeObservers()
        }
    }
}
