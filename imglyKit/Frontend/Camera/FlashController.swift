//
//  FlashController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 12/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

@objc(IMGLYFlashController) public class FlashController: NSObject {

    // MARK: - Properties

    private let session: AVCaptureSession
    private let videoDeviceInput: AVCaptureDeviceInput
    private let sessionQueue: dispatch_queue_t
    private let allowedFlashModes: [AVCaptureFlashMode]

    // MARK: - Initializers

    init(allowedFlashModes: [AVCaptureFlashMode], session: AVCaptureSession, videoDeviceInput: AVCaptureDeviceInput, sessionQueue: dispatch_queue_t) {
        self.allowedFlashModes = allowedFlashModes.count == 0 ? [.On, .Off, .Auto] : allowedFlashModes
        self.session = session
        self.videoDeviceInput = videoDeviceInput
        self.sessionQueue = sessionQueue
        super.init()

        self.flashMode = allowedFlashModes[0]
    }

    // MARK: - Public API

    /**
     Selects the next flash-mode. The order is taken from `availableFlashModes`.
     If the current device does not support a flash mode, this method uses the next flash mode that is supported or .Off.
     */
    public func selectNextFlashMode() {
        let currentFlashModeIndex = allowedFlashModes.indexOf(flashMode) ?? 0
        var nextFlashModeIndex = (currentFlashModeIndex + 1) % allowedFlashModes.count
        var nextFlashMode = allowedFlashModes[nextFlashModeIndex]
        var counter = 1

        while !videoDeviceInput.device.isFlashModeSupported(nextFlashMode) {
            nextFlashModeIndex = (nextFlashModeIndex + 1) % allowedFlashModes.count
            nextFlashMode = allowedFlashModes[nextFlashModeIndex]
            counter++

            if counter >= allowedFlashModes.count {
                nextFlashMode = .Off
                break
            }
        }

        flashMode = nextFlashMode
    }

    public var flashMode: AVCaptureFlashMode {
        get {
            return videoDeviceInput.device.flashMode
        }

        set {
            dispatch_async(sessionQueue) {
                self.session.beginConfiguration()

                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                } catch let error as NSError {
                    print("Error changing flash mode: \(error.description)")
                } catch {
                    fatalError()
                }

                self.videoDeviceInput.device.flashMode = newValue
                self.videoDeviceInput.device.unlockForConfiguration()

                self.session.commitConfiguration()
            }
        }
    }

    public var flashAvailable: Bool {
        return videoDeviceInput.device.flashAvailable
    }
}
