//
//  AVCaptureDeviceExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition? = nil) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devicesWithMediaType(mediaType) as? [AVCaptureDevice] else {
            return nil
        }

        for device in devices where device.position == position {
            return device
        }

        return devices.first
    }
}
