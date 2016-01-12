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

extension SampleBufferController: AVCaptureVideoDataOutputSampleBufferDelegate {
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

        let targetRect = CGRect(x: 0, y: 0, width: videoPreviewView.drawableWidth, height: videoPreviewView.drawableHeight)
        let videoPreviewFrame = sourceImage.extent.rectFittedIntoTargetRect(targetRect, withContentMode: .ScaleAspectFit)

        ciContext.drawImage(sourceImage, inRect: videoPreviewFrame, fromRect: sourceImage.extent)

        videoPreviewView.display()
    }
}
