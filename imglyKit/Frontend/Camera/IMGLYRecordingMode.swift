//
//  IMGLYRecordingMode.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 29/06/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

@objc public enum IMGLYRecordingMode: Int {
    case Photo
    case Video
    
    var bundle: NSBundle {
        return NSBundle(forClass: IMGLYCameraViewController.self)
    }
    
    var titleForSelectionButton: String {
        switch self {
        case .Photo:
            return NSLocalizedString("camera-view-controller.mode.photo", tableName: nil, bundle: bundle, value: "", comment: "")
        case .Video:
            return NSLocalizedString("camera-view-controller.mode.video", tableName: nil, bundle: bundle, value: "", comment: "")
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
            
            for var index = 0; index < 10; index++ {
                let image = String(format: "LensAperture_ShapeLayer_%05d", index)
                button.imageView?.animationImages?.append(UIImage(named: image, inBundle: bundle, compatibleWithTraitCollection:nil)!)
            }
            
            return button
        case .Video:
            let button = IMGLYVideoRecordButton()
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
