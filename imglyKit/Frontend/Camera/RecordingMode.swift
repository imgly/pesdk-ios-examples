//
//  RecordingMode.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 29/06/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

/// The `RecordingMode` determins if a photo or a video should be recorded.
@objc public enum RecordingMode: Int {
    /// Record a Photo.
    case Photo
    /// Record a Video.
    case Video

    var bundle: NSBundle {
        return NSBundle(forClass: CameraViewController.self)
    }

    var titleForSelectionButton: String {
        switch self {
        case .Photo:
            return Localize("PHOTO")
        case .Video:
            return Localize("VIDEO")
        }
    }

    var selectionButton: UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(titleForSelectionButton, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(UIColor(red:1, green:0.8, blue:0, alpha:1), forState: .Selected)
        return button
    }

    var actionButton: UIControl {
        switch self {
        case .Photo:
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(named: "LensAperture_ShapeLayer_00000", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            button.imageView?.animationImages = [UIImage]()
            button.imageView?.animationRepeatCount = 1
            button.adjustsImageWhenHighlighted = false

            for index in 0 ..< 10 {
                let image = String(format: "LensAperture_ShapeLayer_%05d", index)
                button.imageView?.animationImages?.append(UIImage(named: image, inBundle: bundle, compatibleWithTraitCollection:nil)!)
            }

            button.accessibilityLabel = Localize("Take picture")

            return button
        case .Video:
            let button = VideoRecordButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
    }

    var actionSelector: Selector {
        switch self {
        case .Photo:
            return "takePhoto:"
        case .Video:
            return "recordVideo:"
        }
    }

    var sessionPreset: String {
        switch self {
        case .Photo:
            return AVCaptureSessionPresetPhoto
        case .Video:
            return AVCaptureSessionPresetHigh
        }
    }
}
