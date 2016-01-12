//
//  TorchController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 12/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

@objc(IMGLYTorchController) public class TorchController: NSObject {

    // MARK: - Properties

    private let session: AVCaptureSession
    private let videoDeviceInput: AVCaptureDeviceInput
    private let sessionQueue: dispatch_queue_t
    private let allowedTorchModes: [AVCaptureTorchMode]

    // MARK: - Initializers

    init(allowedTorchModes: [AVCaptureTorchMode], session: AVCaptureSession, videoDeviceInput: AVCaptureDeviceInput, sessionQueue: dispatch_queue_t) {
        self.allowedTorchModes = allowedTorchModes.count == 0 ? [.On, .Off, .Auto] : allowedTorchModes
        self.session = session
        self.videoDeviceInput = videoDeviceInput
        self.sessionQueue = sessionQueue
        super.init()

        self.torchMode = allowedTorchModes[0]
    }

    // MARK: - Public API

    /**
     Selects the next torch-mode. The order is Auto->On->Off.
     If the current device does not support auto-torch, this method
     just toggles between on and off.
     */
    public func selectNextTorchMode() {
        let currentTorchModeIndex = allowedTorchModes.indexOf(torchMode) ?? 0
        var nextTorchModeIndex = (currentTorchModeIndex + 1) % allowedTorchModes.count
        var nextTorchMode = allowedTorchModes[nextTorchModeIndex]
        var counter = 1

        while !videoDeviceInput.device.isTorchModeSupported(nextTorchMode) {
            nextTorchModeIndex = (nextTorchModeIndex + 1) % allowedTorchModes.count
            nextTorchMode = allowedTorchModes[nextTorchModeIndex]
            counter++

            if counter >= allowedTorchModes.count {
                nextTorchMode = .Off
                break
            }
        }

        torchMode = nextTorchMode
    }

    public var torchMode: AVCaptureTorchMode {
        get {
            return videoDeviceInput.device.torchMode
        }

        set {
            dispatch_async(sessionQueue) {
                self.session.beginConfiguration()

                if self.videoDeviceInput.device.isTorchModeSupported(newValue) {
                    do {
                        try self.videoDeviceInput.device.lockForConfiguration()
                    } catch let error as NSError {
                        print("Error changing torch mode: \(error.description)")
                    } catch {
                        fatalError()
                    }

                    self.videoDeviceInput.device.torchMode = newValue
                    self.videoDeviceInput.device.unlockForConfiguration()
                }

                self.session.commitConfiguration()
            }
        }
    }

    public var torchAvailable: Bool {
        return videoDeviceInput.device.torchAvailable
    }
}
