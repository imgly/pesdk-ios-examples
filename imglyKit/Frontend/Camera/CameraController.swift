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
    private let allowedCameraPositions: [AVCaptureDevicePosition]
    private let allowedFlashModes: [AVCaptureFlashMode]
    private let allowedTorchModes: [AVCaptureTorchMode]

    private let sampleBufferController: SampleBufferController
    private var flashController: FlashController?
    private var torchController: TorchController?

    // MARK: - Initializer

    public convenience init(allowedCameraPositions: [NSNumber], allowedFlashModes: [NSNumber], allowedTorchModes: [NSNumber]) {
        let cameraPositions = allowedCameraPositions.flatMap { AVCaptureDevicePosition(rawValue: $0.integerValue) }
        let flashModes = allowedFlashModes.flatMap { AVCaptureFlashMode(rawValue: $0.integerValue) }
        let torchModes = allowedTorchModes.flatMap { AVCaptureTorchMode(rawValue: $0.integerValue) }

        self.init(allowedCameraPositions: cameraPositions, allowedFlashModes: flashModes, allowedTorchModes: torchModes)
    }

    public init(allowedCameraPositions: [AVCaptureDevicePosition], allowedFlashModes: [AVCaptureFlashMode], allowedTorchModes: [AVCaptureTorchMode]) {
        self.allowedCameraPositions = allowedCameraPositions.count == 0 ? [.Back, .Front] : allowedCameraPositions
        self.allowedFlashModes = allowedFlashModes
        self.allowedTorchModes = allowedTorchModes

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
        try setupWithInitialCameraPosition(allowedCameraPositions[0], initialSessionPreset: AVCaptureSessionPresetPhoto)
    }

    public func setupWithInitialCameraPosition(initialCameraPosition: AVCaptureDevicePosition, initialSessionPreset: String) throws {
        try setupWithInitialCameraPosition(initialCameraPosition, initialSessionPreset: initialSessionPreset, completion: nil)
    }

    public func setupWithInitialCameraPosition(initialCameraPosition: AVCaptureDevicePosition, initialSessionPreset: String, completion: (() -> Void)?) throws {
        if setupComplete {
            throw CameraControllerError.MultipleCallsToSetup
        }

        guard let videoDevice = AVCaptureDevice.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: initialCameraPosition) else {
            throw CameraControllerError.UnableToInitializeCaptureDevice
        }

        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        self.videoDeviceInput = videoDeviceInput

        flashController = FlashController(allowedFlashModes: allowedFlashModes, session: session, videoDeviceInput: videoDeviceInput, sessionQueue: sessionQueue)
        torchController = TorchController(allowedTorchModes: allowedTorchModes, session: session, videoDeviceInput: videoDeviceInput, sessionQueue: sessionQueue)

        dispatch_async(sessionQueue) {
            self.session.beginConfiguration()
            self.addVideoDeviceInput(videoDeviceInput)
            self.addVideoDataOutput(self.videoDataOutput)
            self.changeSessionPreset(initialSessionPreset)
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

        videoPreviewView.bindDrawable()

        dispatch_async(sessionQueue) {
            self.addObservers()
            self.session.startRunning()
        }
    }

    public func stopCamera() {
        dispatch_async(sessionQueue) {
            self.session.stopRunning()
            self.removeObservers()
        }
    }
}
