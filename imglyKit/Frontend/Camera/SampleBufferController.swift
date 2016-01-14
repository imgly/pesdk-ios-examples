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

    // MARK: - Initializers

    init(videoPreviewView: GLKView) {
        self.videoPreviewView = videoPreviewView

        let options: [String: AnyObject]?
        if let colorSpace = CGColorSpaceCreateDeviceRGB() {
            options = [kCIContextWorkingColorSpace: colorSpace]
        } else {
            options = nil
        }

        ciContext = CIContext(EAGLContext: self.videoPreviewView.context, options: options)

        super.init()
    }

}

extension SampleBufferController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

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

        ciContext.drawImage(filteredImage, inRect: videoPreviewFrame, fromRect: filteredImage.extent)

        videoPreviewView.display()
    }
}
