//
//  AVCaptureVideoOrientationExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import AVFoundation

extension AVCaptureVideoOrientation {
    func toTransform(mirrored: Bool = false) -> CGAffineTransform {
        let result: CGAffineTransform

        switch self {
        case .Portrait:
            result = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        case .PortraitUpsideDown:
            result = CGAffineTransformMakeRotation(CGFloat(3 * M_PI_2))
        case .LandscapeRight:
            result = mirrored ? CGAffineTransformMakeRotation(CGFloat(M_PI)) : CGAffineTransformIdentity
        case .LandscapeLeft:
            result = mirrored ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(CGFloat(M_PI))
        }

        return result
    }
}
