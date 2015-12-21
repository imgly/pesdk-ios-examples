//
//  NSAffineTransformExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 30/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(OSX)

import Foundation

extension NSAffineTransform {
    convenience init(CGAffineTransform transform: CGAffineTransform) {
        self.init()
        self.transformStruct.m11 = transform.a
        self.transformStruct.m12 = transform.b
        self.transformStruct.m21 = transform.c
        self.transformStruct.m22 = transform.d
        self.transformStruct.tX = transform.tx
        self.transformStruct.tY = transform.ty
    }
}

#endif
