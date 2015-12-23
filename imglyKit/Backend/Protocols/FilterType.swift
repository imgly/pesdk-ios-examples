//
//  FilterType.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/12/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
#if os(iOS)
import CoreImage
#elseif os(OSX)
import QuartzCore
#endif

@objc public protocol FilterType: NSCopying {
    var inputImage: CIImage? { get set }
    var outputImage: CIImage? { get }
}
