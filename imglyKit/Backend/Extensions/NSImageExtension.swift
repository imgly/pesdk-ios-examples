//
//  NSImageExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 30/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(OSX)

import AppKit
import CoreGraphics

public extension NSImage {
    var CGImage: CoreGraphics.CGImage? {
        let cgImage = CGImageForProposedRect(nil, context: nil, hints: nil)
        return cgImage
    }
}

#endif
