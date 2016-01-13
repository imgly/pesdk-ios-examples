//
//  FlashController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 12/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

class FlashController: NSObject {

    // MARK: - Properties

    private let session: AVCaptureSession
    private let videoDeviceInput: AVCaptureDeviceInput
    private let sessionQueue: dispatch_queue_t

    var flashModes: [AVCaptureFlashMode] {
        didSet {
            if flashModes.count == 0 {
                flashModes = oldValue
            }

            if oldValue != flashModes {
                flashModes = flashModes.filter { videoDeviceInput.device.isFlashModeSupported($0) }
                if flashModes.count == 0 {
                    flashModes = [.Off]
                }

                // Update current flash mode if it is not in the list of supported flash modes
                if !flashModes.contains(flashMode) {
                    selectNextFlashMode()
                }
            }
        }
    }

    // MARK: - Initializers

    init(flashModes: [AVCaptureFlashMode], session: AVCaptureSession, videoDeviceInput: AVCaptureDeviceInput, sessionQueue: dispatch_queue_t) {
        self.session = session
        self.videoDeviceInput = videoDeviceInput
        self.sessionQueue = sessionQueue

        // Set to all available flash modes
        self.flashModes = (flashModes.count == 0 ? [.On, .Off, .Auto] : flashModes).filter { videoDeviceInput.device.isFlashModeSupported($0) }
        if self.flashModes.count == 0 {
            self.flashModes = [.Off]
        }

        super.init()

        self.flashMode = flashModes[0]
    }

    // MARK: - Public API

    /**
    Selects the next flash-mode. The order is taken from `availableFlashModes`.
    If the current device does not support a flash mode, this method uses the next flash mode that is supported or .Off.
    */
    func selectNextFlashMode() {
        let currentFlashModeIndex = flashModes.indexOf(flashMode) ?? -1
        var nextFlashModeIndex = (currentFlashModeIndex + 1) % flashModes.count
        var nextFlashMode = flashModes[nextFlashModeIndex]
        var counter = 1

        while !videoDeviceInput.device.isFlashModeSupported(nextFlashMode) {
            nextFlashModeIndex = (nextFlashModeIndex + 1) % flashModes.count
            nextFlashMode = flashModes[nextFlashModeIndex]
            counter++

            if counter >= flashModes.count {
                nextFlashMode = .Off
                break
            }
        }

        flashMode = nextFlashMode
    }

    dynamic var hasFlash: Bool {
        return videoDeviceInput.device.hasFlash
    }

    dynamic private(set) var flashMode: AVCaptureFlashMode {
        get {
            return videoDeviceInput.device.flashMode
        }

        set {
            dispatch_async(sessionQueue) {
                if self.videoDeviceInput.device.isFlashModeSupported(newValue) {
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
    }

    dynamic var flashAvailable: Bool {
        return videoDeviceInput.device.flashAvailable
    }

    // MARK: - KVO

    @objc private class func keyPathsForValuesAffectingHasFlash() -> Set<String> {
        return ["videoDeviceInput.device.hasFlash"]
    }

    @objc private class func keyPathsForValuesAffectingFlashMode() -> Set<String> {
        return ["videoDeviceInput.device.flashMode"]
    }

    @objc private class func keyPathsForValuesAffectingFlashAvailable() -> Set<String> {
        return ["videoDeviceInput.device.flashAvailable"]
    }
}
