//
//  VideoController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 15/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class VideoController {

    // MARK: - Properties

    private let videoOutputSettings: [String: AnyObject]?
    private let audioOutputSettings: [String: AnyObject]?

    private let sampleBufferQueue: dispatch_queue_t

    private(set) var assetWriter: AVAssetWriter?
    private(set) var assetWriterVideoInput: AVAssetWriterInput?
    private(set) var assetWriterAudioInput: AVAssetWriterInput?
    private(set) var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?

    var videoWritingStartTime: CMTime?
    var currentVideoTime: CMTime?
    private var timeUpdateTimer: NSTimer?

    var videoWritingStarted = false

    private let videoRecordingHandler: ((started: Bool, failed: Bool, fileURL: NSURL?, timeRecorded: Int?) -> Void)

    // MARK: - Initializers

    init(videoOutputSettings: [String: AnyObject]?, audioOutputSettings: [String: AnyObject]?, sampleBufferQueue: dispatch_queue_t, videoRecordingHandler: ((started: Bool, failed: Bool, fileURL: NSURL?, timeRecorded: Int?) -> Void)) {
        self.videoOutputSettings = videoOutputSettings
        self.audioOutputSettings = audioOutputSettings
        self.sampleBufferQueue = sampleBufferQueue
        self.videoRecordingHandler = videoRecordingHandler
    }

    // MARK: - Writing

    func startWritingWithVideoDimensions(videoDimensions: CMVideoDimensions?, orientation: AVCaptureVideoOrientation?, cameraPosition: AVCaptureDevicePosition, recordAudio: Bool) {
        if assetWriter != nil {
            return
        }

        let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoOutputSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        self.assetWriterVideoInput = assetWriterVideoInput

        var sourcePixelBufferAttributes: [String: AnyObject] = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(unsignedInt: kCVPixelFormatType_32BGRA), String(kCVPixelFormatOpenGLESCompatibility): kCFBooleanTrue]
        if let videoDimensions = videoDimensions {
            sourcePixelBufferAttributes[String(kCVPixelBufferWidthKey)] = NSNumber(int: videoDimensions.width)
            sourcePixelBufferAttributes[String(kCVPixelBufferHeightKey)] = NSNumber(int: videoDimensions.height)
        }

        assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)

        let filename = (NSProcessInfo.processInfo().globallyUniqueString as NSString).stringByAppendingPathExtension("mov")
        let outputFileURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(filename!))
        _ = try? NSFileManager.defaultManager().removeItemAtURL(outputFileURL)

        guard let newAssetWriter = try? AVAssetWriter(URL: outputFileURL, fileType: AVFileTypeQuickTimeMovie) else {
            videoRecordingHandler(started: false, failed: true, fileURL: nil, timeRecorded: 0)
            return
        }

        if let captureVideoOrientation = orientation {
            if cameraPosition == .Front {
                assetWriterVideoInput.transform = captureVideoOrientation.toTransform(true)
            } else {
                assetWriterVideoInput.transform = captureVideoOrientation.toTransform()
            }
        }

        let canAddInput = newAssetWriter.canAddInput(assetWriterVideoInput)
        if !canAddInput {
            videoRecordingHandler(started: false, failed: true, fileURL: nil, timeRecorded: 0)
            return
        }

        newAssetWriter.addInput(assetWriterVideoInput)

        if recordAudio {
            if newAssetWriter.canApplyOutputSettings(audioOutputSettings, forMediaType: AVMediaTypeAudio) {
                let assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
                assetWriterAudioInput.expectsMediaDataInRealTime = true

                if newAssetWriter.canAddInput(assetWriterAudioInput) {
                    newAssetWriter.addInput(assetWriterAudioInput)
                    self.assetWriterAudioInput = assetWriterAudioInput
                }
            }
        }

        if UIDevice.currentDevice().multitaskingSupported {
            backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        }

        videoWritingStarted = false
        assetWriter = newAssetWriter
        startTimeUpdateTimer()
        videoRecordingHandler(started: true, failed: false, fileURL: nil, timeRecorded: nil)
    }

    func abortWriting() {
        guard let assetWriter = assetWriter else {
            return
        }

        dispatch_async(sampleBufferQueue) {
            _ = try? NSFileManager.defaultManager().removeItemAtURL(assetWriter.outputURL)

            assetWriter.cancelWriting()
            self.assetWriterAudioInput = nil
            self.assetWriterVideoInput = nil
            self.videoWritingStartTime = nil
            self.currentVideoTime = nil
            self.assetWriter = nil
            self.stopTimeUpdateTimer()

            // End background task
            if let backgroundRecordingID = self.backgroundRecordingID where UIDevice.currentDevice().multitaskingSupported {
                UIApplication.sharedApplication().endBackgroundTask(backgroundRecordingID)
            }

            self.videoRecordingHandler(started: false, failed: true, fileURL: nil, timeRecorded: nil)
        }
    }

    func stopWritingWithCompletionHandler(completionHandler: (() -> Void)?) {
        guard let assetWriter = assetWriter else {
            return
        }

        dispatch_async(sampleBufferQueue) {
            self.assetWriterAudioInput = nil
            self.assetWriterVideoInput = nil
            self.videoWritingStartTime = nil
            self.currentVideoTime = nil
            self.assetWriter = nil

            if assetWriter.status == .Unknown {
                self.videoRecordingHandler(started: false, failed: true, fileURL: nil, timeRecorded: nil)
                return
            }

            assetWriter.finishWritingWithCompletionHandler {
                self.stopTimeUpdateTimer()

                if assetWriter.status == .Failed {
                    if let backgroundRecordingID = self.backgroundRecordingID {
                        UIApplication.sharedApplication().endBackgroundTask(backgroundRecordingID)
                    }

                    self.videoRecordingHandler(started: false, failed: true, fileURL: nil, timeRecorded: nil)
                } else if assetWriter.status == .Completed {
                    self.videoRecordingHandler(started: false, failed: false, fileURL: assetWriter.outputURL, timeRecorded: nil)

                    if let backgroundRecordingID = self.backgroundRecordingID {
                        UIApplication.sharedApplication().endBackgroundTask(backgroundRecordingID)

                        completionHandler?()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func startTimeUpdateTimer() {
        dispatch_async(dispatch_get_main_queue()) {
            if let timeUpdateTimer = self.timeUpdateTimer {
                timeUpdateTimer.invalidate()
            }

            self.timeUpdateTimer = NSTimer.after(0.25, repeats: true, { () -> () in
                if let currentVideoTime = self.currentVideoTime, videoWritingStartTime = self.videoWritingStartTime {
                    let diff = CMTimeSubtract(currentVideoTime, videoWritingStartTime)
                    let seconds = Int(CMTimeGetSeconds(diff))

                    self.videoRecordingHandler(started: false, failed: false, fileURL: nil, timeRecorded: seconds)
                }
            })
        }
    }

    private func stopTimeUpdateTimer() {
        dispatch_async(dispatch_get_main_queue()) {
            self.timeUpdateTimer?.invalidate()
            self.timeUpdateTimer = nil
        }
    }
}
