//
//  FocusController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 19/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import GLKit

private var focusControllerContext = 0

final class FocusController: NSObject {

    // MARK: - Properties

    private let videoDeviceInput: AVCaptureDeviceInput
    private let videoPreviewView: GLKView
    private let sessionQueue: dispatch_queue_t
    private let tapGestureRecognizer: UITapGestureRecognizer
    var videoPreviewFrame: CGRect?
    var handler: ((point: CGPoint?, mode: (AVCaptureFocusMode, AVCaptureExposureMode)?, disabled: Bool) -> Void)?

    // MARK: - Initializers

    init(videoDeviceInput: AVCaptureDeviceInput, videoPreviewView: GLKView, videoPreviewFrame: CGRect?, sessionQueue: dispatch_queue_t) {
        self.videoDeviceInput = videoDeviceInput
        self.videoPreviewView = videoPreviewView
        self.sessionQueue = sessionQueue
        tapGestureRecognizer = UITapGestureRecognizer()

        super.init()

        videoDeviceInput.device.addObserver(self, forKeyPath: "focusMode", options: [.Old, .New], context: &focusControllerContext)
        videoDeviceInput.device.addObserver(self, forKeyPath: "exposureMode", options: [.Old, .New], context: &focusControllerContext)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDeviceInput.device)

        tapGestureRecognizer.addTarget(self, action: "tapped:")
        videoPreviewView.addGestureRecognizer(tapGestureRecognizer)
    }

    deinit {
        videoDeviceInput.device.removeObserver(self, forKeyPath: "focusMode", context: &focusControllerContext)
        videoDeviceInput.device.removeObserver(self, forKeyPath: "exposureMode", context: &focusControllerContext)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDeviceInput.device)
    }

    // MARK: - API

    private var focusPointSupported: Bool {
        return videoDeviceInput.device.focusPointOfInterestSupported && videoDeviceInput.device.isFocusModeSupported(.AutoFocus) && videoDeviceInput.device.isFocusModeSupported(.ContinuousAutoFocus)
    }

    private var exposurePointSupported: Bool {
        return videoDeviceInput.device.exposurePointOfInterestSupported && videoDeviceInput.device.isExposureModeSupported(.AutoExpose) && videoDeviceInput.device.isExposureModeSupported(.ContinuousAutoExposure)
    }

    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        if let videoPreviewFrame = videoPreviewFrame where focusPointSupported || exposurePointSupported {
            let focusPointLocation = recognizer.locationInView(videoPreviewView)
            let scaleFactor = videoPreviewView.contentScaleFactor
            let videoFrame = CGRect(
                x: videoPreviewFrame.minX / scaleFactor,
                y: videoPreviewFrame.minY / scaleFactor,
                width: videoPreviewFrame.width / scaleFactor,
                height: videoPreviewFrame.height / scaleFactor
            )

            if CGRectContainsPoint(videoFrame, focusPointLocation) {
                handler?(point: focusPointLocation, mode: nil, disabled: false)

                var pointOfInterest = CGPoint(
                    x: focusPointLocation.x / videoFrame.width,
                    y: focusPointLocation.y / videoFrame.height
                )
                pointOfInterest.x = 1 - pointOfInterest.x

                if videoDeviceInput.device.position == .Front {
                    pointOfInterest.y = 1 - pointOfInterest.y
                }

                focusWithMode(.AutoFocus, exposeWithMode: .AutoExpose, atDevicePoint: pointOfInterest, monitorSubjectAreaChange: true)
            }
        }
    }

    private func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(sessionQueue) {
            let device = self.videoDeviceInput.device
            var error: NSError?

            do {
                try device.lockForConfiguration()
                if self.focusPointSupported {
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }

                if self.exposurePointSupported {
                    device.exposureMode = exposureMode
                    device.exposurePointOfInterest = point
                }

                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch let error1 as NSError {
                error = error1
                print("Error in focusWithMode:exposeWithMode:atDevicePoint:monitorSubjectAreaChange: \(error?.description)")
            } catch {
                fatalError()
            }
        }
    }

    @objc private func subjectAreaDidChange(notification: NSNotification) {
        disableFocusLock()
    }

    private func disableFocusLock() {
        if focusPointSupported || exposurePointSupported {
            focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: CGPoint(x: 0.5, y: 0.5), monitorSubjectAreaChange: false)
        }

        handler?(point: nil, mode: nil, disabled: true)
    }

    // MARK: - KVO

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath where context == &focusControllerContext {
            switch keyPath {
            case "focusMode", "exposureMode":
                handler?(point: nil, mode: (videoDeviceInput.device.focusMode, videoDeviceInput.device.exposureMode), disabled: false)
            default:
                break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}
