//
//  CIFilterExtension.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 22/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import ObjectiveC
#if os(iOS)
import CoreImage
#elseif os(OSX)
import QuartzCore
#endif

private var displayNameAssociationKey: UInt8 = 0

public extension CIFilter {
    public var imgly_displayName: String? {
        get {
            return objc_getAssociatedObject(self, &displayNameAssociationKey) as? String
        }

        set(newValue) {
            objc_setAssociatedObject(self, &displayNameAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
