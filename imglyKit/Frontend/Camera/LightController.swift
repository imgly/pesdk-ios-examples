//
//  LightController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 14/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import AVFoundation

@objc enum LightMode: Int {
    case Off
    case On
    case Auto

    init(flashMode: AVCaptureFlashMode) {
        switch flashMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }

    init(torchMode: AVCaptureTorchMode) {
        switch torchMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }
}

extension AVCaptureFlashMode {
    init(lightMode: LightMode) {
        switch lightMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }
}

extension AVCaptureTorchMode {
    init(lightMode: LightMode) {
        switch lightMode {
        case .Off:
            self = .Off
        case .On:
            self = .On
        case .Auto:
            self = .Auto
        }
    }
}

protocol LightControllable {
    var lightModes: [LightMode] { get set }
    func selectNextLightMode()
    var hasLight: Bool { get }
    var lightMode: LightMode { get }
    var lightAvailable: Bool { get }
}