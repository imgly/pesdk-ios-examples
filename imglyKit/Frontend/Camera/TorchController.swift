//
//  TorchController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 12/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

class TorchController: NSObject {

    // MARK: - Properties

    private let session: AVCaptureSession
    private let videoDeviceInput: AVCaptureDeviceInput
    private let sessionQueue: dispatch_queue_t

    var torchModes: [AVCaptureTorchMode] {
        didSet {
            if torchModes.count == 0 {
                torchModes = oldValue
            }

            if oldValue != torchModes {
                torchModes = torchModes.filter { videoDeviceInput.device.isTorchModeSupported($0) }
                if torchModes.count == 0 {
                    torchModes = [.Off]
                }

                // Update current flash mode if it is not in the list of supported flash modes
                if !torchModes.contains(torchMode) {
                    selectNextTorchMode()
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
        self.torchModes = (torchModes.count == 0 ? [.On, .Off, .Auto] : torchModes).filter { videoDeviceInput.device.isTorchModeSupported($0) }
        if self.torchModes.count == 0 {
            self.torchModes = [.Off]
        }

        super.init()

        self.torchMode = torchModes[0]
    }

    // MARK: - Public API

    /**
    Selects the next torch-mode. The order is taken from `availableTorchModes`.
    If the current device does not support a torch mode, this method uses the next torch mode that is supported or .Off.
    */
    func selectNextTorchMode() {
        let currentTorchModeIndex = torchModes.indexOf(torchMode) ?? -1
        var nextTorchModeIndex = (currentTorchModeIndex + 1) % torchModes.count
        var nextTorchMode = torchModes[nextTorchModeIndex]
        var counter = 1

        while !videoDeviceInput.device.isTorchModeSupported(nextTorchMode) {
            nextTorchModeIndex = (nextTorchModeIndex + 1) % torchModes.count
            nextTorchMode = torchModes[nextTorchModeIndex]
            counter++

            if counter >= torchModes.count {
                nextTorchMode = .Off
                break
            }
        }

        torchMode = nextTorchMode
    }

    dynamic var hasTorch: Bool {
        return videoDeviceInput.device.hasTorch
    }

    dynamic private(set) var torchMode: AVCaptureTorchMode {
        get {
            return videoDeviceInput.device.torchMode
        }

        set {
            dispatch_async(sessionQueue) {
                if self.videoDeviceInput.device.isTorchModeSupported(newValue) {
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
    }

    dynamic var torchAvailable: Bool {
        return videoDeviceInput.device.torchAvailable
    }

    // MARK: - KVO

    @objc private class func keyPathsForValuesAffectingHasTorch() -> Set<String> {
        return ["videoDeviceInput.device.hasTorch"]
    }

    @objc private class func keyPathsForValuesAffectingTorchMode() -> Set<String> {
        return ["videoDeviceInput.device.torchMode"]
    }

    @objc private class func keyPathsForValuesAffectingTorchAvailable() -> Set<String> {
        return ["videoDeviceInput.device.torchAvailable"]
    }
}
