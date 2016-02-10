//
//  SampleBufferController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation
import CoreImage
import GLKit

class SampleBufferController: NSObject {

    // MARK: - Properties

    let videoPreviewView: GLKView
    let ciContext: CIContext
    var effectFilter: EffectFilter = NoneFilter()
    var videoController: VideoController?
    var previewFrameChangedHandler: ((previewFrame: CGRect) -> Void)?

    private(set) var currentPreviewFrame: CGRect? {
        didSet {
            if let currentPreviewFrame = currentPreviewFrame where oldValue != currentPreviewFrame {
                previewFrameChangedHandler?(previewFrame: currentPreviewFrame)
            }
        }
    }
    private(set) var currentVideoDimensions: CMVideoDimensions?

    // MARK: - Initializers

    init(videoPreviewView: GLKView) {
        self.videoPreviewView = videoPreviewView
        ciContext = CIContext(EAGLContext: self.videoPreviewView.context, options: nil)

        super.init()
    }

}

extension SampleBufferController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }

        let mediaType = CMFormatDescriptionGetMediaType(formatDescription)

        // Handle Audio Recording
        if mediaType == CMMediaType(kCMMediaType_Audio) {
            if let assetWriterAudioInput = videoController?.assetWriterAudioInput where assetWriterAudioInput.readyForMoreMediaData {
                let success = assetWriterAudioInput.appendSampleBuffer(sampleBuffer)
                if !success {
                    videoController?.abortWriting()
                }
            }

            return
        }

        // Handle Video
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)

        let sourceImage: CIImage
        if #available(iOS 9.0, *) {
            sourceImage = CIImage(CVImageBuffer: imageBuffer)
        } else {
            sourceImage = CIImage(CVPixelBuffer: imageBuffer as CVPixelBuffer)
        }

        let filteredImage: CIImage
        if effectFilter is NoneFilter {
            filteredImage = sourceImage
        } else {
            filteredImage = PhotoProcessor.processWithCIImage(sourceImage, filters: [effectFilter]) ?? sourceImage
        }

        let targetRect = CGRect(x: 0, y: 0, width: videoPreviewView.drawableWidth, height: videoPreviewView.drawableHeight)
        let videoPreviewFrame = sourceImage.extent.rectFittedIntoTargetRect(targetRect, withContentMode: .ScaleAspectFit)

        glClearColor(0, 0, 0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        // Handle Video Recording
        if let videoController = videoController, assetWriter = videoController.assetWriter, assetWriterVideoInput = videoController.assetWriterVideoInput {
            videoController.currentVideoTime = timestamp

            if !videoController.videoWritingStarted {
                videoController.videoWritingStarted = true

                let success = assetWriter.startWriting()
                if !success {
                    videoController.abortWriting()
                    return
                }

                assetWriter.startSessionAtSourceTime(timestamp)
                videoController.videoWritingStartTime = timestamp
            }

            let assetWriterInputPixelBufferAdaptor = videoController.assetWriterInputPixelBufferAdaptor
            if let pixelBufferPool = assetWriterInputPixelBufferAdaptor?.pixelBufferPool {
                var renderedOutputPixelBuffer: CVPixelBuffer?
                let status = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &renderedOutputPixelBuffer)
                if status != 0 {
                    videoController.abortWriting()
                    return
                }

                if let renderedOutputPixelBuffer = renderedOutputPixelBuffer {
                    ciContext.render(filteredImage, toCVPixelBuffer: renderedOutputPixelBuffer)

                    let drawImage = CIImage(CVPixelBuffer: renderedOutputPixelBuffer)
                    ciContext.drawImage(drawImage, inRect: videoPreviewFrame, fromRect: filteredImage.extent)

                    if assetWriterVideoInput.readyForMoreMediaData {
                        assetWriterInputPixelBufferAdaptor?.appendPixelBuffer(renderedOutputPixelBuffer, withPresentationTime: timestamp)
                    }
                }
            }
        } else {
            // Handle Live Preview (no recording session)
            ciContext.drawImage(filteredImage, inRect: videoPreviewFrame, fromRect: filteredImage.extent)
        }

        currentPreviewFrame = videoPreviewFrame
        videoPreviewView.display()
    }
}
