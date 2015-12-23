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
    // swiftlint:disable variable_name
    var CGImage: CoreGraphics.CGImage? {
        let cgImage = CGImageForProposedRect(nil, context: nil, hints: nil)
        return cgImage
    }
    // swiftlint:enable variable?name
}

#endif
