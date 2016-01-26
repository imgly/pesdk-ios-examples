//
//  TorchController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 12/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

final class TorchController: NSObject, LightControllable {

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
                lightModes = lightModes.filter { videoDeviceInput.device.isTorchModeSupported(AVCaptureTorchMode(lightMode: $0)) }
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

    init(torchModes: [AVCaptureTorchMode], session: AVCaptureSession, videoDeviceInput: AVCaptureDeviceInput, sessionQueue: dispatch_queue_t) {
        self.session = session
        self.videoDeviceInput = videoDeviceInput
        self.sessionQueue = sessionQueue

        // Set to all available flash modes
        lightModes = (torchModes.count == 0 ? [.On, .Off, .Auto] : torchModes).filter { videoDeviceInput.device.isTorchModeSupported($0) }.map { LightMode(torchMode: $0) }
        if lightModes.count == 0 {
            lightModes = [.Off]
        }

        super.init()

        if !lightModes.contains(lightMode) {
            lightMode = lightModes[0]
        }
    }

    // MARK: - Public API

    /**
    Selects the next torch-mode. The order is taken from `availableTorchModes`.
    If the current device does not support a torch mode, this method uses the next torch mode that is supported or .Off.
    */
    func selectNextLightMode() {
        let currentTorchModeIndex = lightModes.indexOf(lightMode) ?? -1
        var nextTorchModeIndex = (currentTorchModeIndex + 1) % lightModes.count
        var nextTorchMode = lightModes[nextTorchModeIndex]
        var counter = 1

        while !videoDeviceInput.device.isTorchModeSupported(AVCaptureTorchMode(lightMode: nextTorchMode)) {
            nextTorchModeIndex = (nextTorchModeIndex + 1) % lightModes.count
            nextTorchMode = lightModes[nextTorchModeIndex]
            counter += 1

            if counter >= lightModes.count {
                nextTorchMode = .Off
                break
            }
        }

        lightMode = nextTorchMode
    }

    var hasLight: Bool {
        return videoDeviceInput.device.hasTorch
    }

    private(set) var lightMode: LightMode {
        get {
            return LightMode(torchMode: videoDeviceInput.device.torchMode)
        }

        set {
            dispatch_async(sessionQueue) {
                if self.videoDeviceInput.device.isTorchModeSupported(AVCaptureTorchMode(lightMode: newValue)) {
                    self.session.beginConfiguration()

                    do {
                        try self.videoDeviceInput.device.lockForConfiguration()
                    } catch let error as NSError {
                        print("Error changing torch mode: \(error.description)")
                    } catch {
                        fatalError()
                    }

                    self.videoDeviceInput.device.torchMode = AVCaptureTorchMode(lightMode: newValue)
                    self.videoDeviceInput.device.unlockForConfiguration()
                    self.session.commitConfiguration()
                }
            }
        }
    }

    var lightAvailable: Bool {
        return videoDeviceInput.device.torchAvailable
    }

    // MARK: - KVO

    @objc private class func keyPathsForValuesAffectingHasLight() -> Set<String> {
        return ["videoDeviceInput.device.hasTorch"]
    }

    @objc private class func keyPathsForValuesAffectingLightMode() -> Set<String> {
        return ["videoDeviceInput.device.torchMode"]
    }

    @objc private class func keyPathsForValuesAffectingLightAvailable() -> Set<String> {
        return ["videoDeviceInput.device.torchAvailable"]
    }
}
