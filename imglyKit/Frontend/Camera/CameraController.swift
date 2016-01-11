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
    private let ciContext: CIContext
    public let videoPreviewView: GLKView

    private var setupComplete = false

    private let sampleBufferController: SampleBufferController

    // MARK: - Initializer

    public override init() {
        guard let glContext = EAGLContext(API: .OpenGLES2) else {
            fatalError("Unable to create EAGLContext")
        }

        self.glContext = glContext

        let options: [String: AnyObject]?
        if let colorSpace = CGColorSpaceCreateDeviceRGB() {
            options = [kCIContextWorkingColorSpace: colorSpace]
        } else {
            options = nil
        }

        ciContext = CIContext(EAGLContext: glContext, options: options)
        videoPreviewView = GLKView(frame: CGRectZero, context: glContext)
        videoPreviewView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        sampleBufferController = SampleBufferController(
            videoPreviewView: videoPreviewView,
            ciContext: ciContext
        )

        super.init()
    }

    // MARK: - Session Notifications

    private func addSessionObservers() {
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
        try setupWithInitialCameraPosition(.Back, initialSessionPreset: AVCaptureSessionPresetPhoto)
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

        dispatch_async(sessionQueue) {
            self.session.beginConfiguration()
            self.addVideoDeviceInput(videoDeviceInput)
            self.addVideoDataOutput(self.videoDataOutput)
            self.changeSessionPreset(initialSessionPreset)
            self.session.commitConfiguration()
            completion?()
        }

        setupComplete = true
    }

    // MARK: - Session Configuration

    private func addVideoDeviceInput(videoDeviceInput: AVCaptureDeviceInput) {
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        }

        dispatch_async(dispatch_get_main_queue()) {
            switch videoDeviceInput.device.position {
            case .Front:
                // front camera is mirrored so we need to transform the preview view
                self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.videoPreviewView.transform = CGAffineTransformScale(self.videoPreviewView.transform, 1, -1)
            case .Back:
                self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            case .Unspecified:
                break
            }
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
        assert(setupComplete, "setup() needs to be called before calling startCamera()")

        videoPreviewView.bindDrawable()

        dispatch_async(sessionQueue) {
            self.session.startRunning()
        }
    }

    public func stopCamera() {
        assert(setupComplete, "setup() needs to be called before calling stopCamera()")

        dispatch_async(sessionQueue) {
            self.session.stopRunning()
        }
    }
}
