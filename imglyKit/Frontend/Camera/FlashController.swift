//
//  FlashController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 12/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

class FlashController: NSObject, LightControllable {

    // MARK: - Properties

    private let session: AVCaptureSession
    private dynamic let videoDeviceInput: AVCaptureDeviceInput
    private let sessionQueue: dispatch_queue_t

    var lightModes: [LightMode] {
        didSet {
            if lightModes.count == 0 {
                lightModes = oldValue
            }

            if oldValue != lightModes {
                lightModes = lightModes.filter { videoDeviceInput.device.isFlashModeSupported(AVCaptureFlashMode(lightMode: $0)) }
                if lightModes.count == 0 {
                    lightModes = [.Off]
                }

                // Update current flash mode if it is not in the list of supported flash modes
                if !lightModes.contains(lightMode) {
                    selectNextLightMode()
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
        lightModes = (flashModes.count == 0 ? [.On, .Off, .Auto] : flashModes).filter { videoDeviceInput.device.isFlashModeSupported($0) }.map { LightMode(flashMode: $0) }
        if lightModes.count == 0 {
            lightModes = [.Off]
        }

        super.init()

        if !lightModes.contains(lightMode) {
            lightMode = lightModes[0]
        }
    }

    // MARK: - Public API

    func selectNextLightMode() {
        let currentFlashModeIndex = lightModes.indexOf(lightMode) ?? -1
        var nextFlashModeIndex = (currentFlashModeIndex + 1) % lightModes.count
        var nextFlashMode = lightModes[nextFlashModeIndex]
        var counter = 1

        while !videoDeviceInput.device.isFlashModeSupported(AVCaptureFlashMode(lightMode: nextFlashMode)) {
            nextFlashModeIndex = (nextFlashModeIndex + 1) % lightModes.count
            nextFlashMode = lightModes[nextFlashModeIndex]
            counter++

            if counter >= lightModes.count {
                nextFlashMode = .Off
                break
            }
        }

        lightMode = nextFlashMode
    }

    var hasLight: Bool {
        return videoDeviceInput.device.hasFlash
    }

    private(set) var lightMode: LightMode {
        get {
            return LightMode(flashMode: videoDeviceInput.device.flashMode)
        }

        set {
            dispatch_async(sessionQueue) {
                if self.videoDeviceInput.device.isFlashModeSupported(AVCaptureFlashMode(lightMode: newValue)) {
                    self.session.beginConfiguration()

                    do {
                        try self.videoDeviceInput.device.lockForConfiguration()
                    } catch let error as NSError {
                        print("Error changing flash mode: \(error.description)")
                    } catch {
                        fatalError()
                    }

                    self.videoDeviceInput.device.flashMode = AVCaptureFlashMode(lightMode: newValue)
                    self.videoDeviceInput.device.unlockForConfiguration()
                    self.session.commitConfiguration()
                }
            }
        }
    }

    var lightAvailable: Bool {
        return videoDeviceInput.device.flashAvailable
    }

    // MARK: - KVO

    @objc private class func keyPathsForValuesAffectingHasLight() -> Set<String> {
        return ["videoDeviceInput.device.hasFlash"]
    }

    @objc private class func keyPathsForValuesAffectingLightMode() -> Set<String> {
        return ["videoDeviceInput.device.flashMode"]
    }

    @objc private class func keyPathsForValuesAffectingLightAvailable() -> Set<String> {
        return ["videoDeviceInput.device.flashAvailable"]
    }
}
