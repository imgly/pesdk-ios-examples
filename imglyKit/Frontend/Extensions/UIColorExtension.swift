//
//  UIColorExtension.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

public class HSB {
    public var hue = CGFloat(0)
    public var saturation = CGFloat(0)
    public var brightness = CGFloat(0)
}

public extension UIColor {
    public var hsb: HSB {
        let hsb = HSB()

        let model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))
        if (model == CGColorSpaceModel.Monochrome) || (model == CGColorSpaceModel.RGB) {
            let c = CGColorGetComponents(self.CGColor)

            var x = min(c[0], c[1])
            x = min(x, c[2])

            var b = max(c[0], c[1])
            b = max(b, c[2])

            if (b == x) {
                hsb.brightness = b
            }
            else {
                let f = CGFloat((c[0] == x) ? c[1] - c[2] : ((c[1] == x) ? c[2] - c[0] : c[0] - c[1]))
                let i = CGFloat((c[0] == x) ? 3 : ((c[1] == x) ? 5 : 1))

                hsb.hue = ((i - f / (b - x)) / 6)
                hsb.saturation = (b - x) / b
                hsb.brightness = b
            }
        }
        return hsb
    }
}