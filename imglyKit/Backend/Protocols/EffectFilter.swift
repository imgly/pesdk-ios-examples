//
//  EffectFilter.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/12/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYEffectFilter) public protocol EffectFilter: Filter {
    var filterType: FilterType { get }
    var displayName: String { get }
    var inputIntensity: NSNumber { get set }
}
