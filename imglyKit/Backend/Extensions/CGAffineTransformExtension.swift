//
//  CGAffineTransformExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 29/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import CoreImage

extension CGAffineTransform {
    var xScale: CGFloat {
        return sqrt(a * a + c * c)
    }

    var yScale: CGFloat {
        return sqrt(b * b + d * d)
    }

    var rotation: CGFloat {
        return atan2(b, a)
    }
}
