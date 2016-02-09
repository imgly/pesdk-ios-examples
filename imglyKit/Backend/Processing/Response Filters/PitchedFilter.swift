//
//  PitchedFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYPitchedFilter) public class PitchedFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Pitched")
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension PitchedFilter: EffectFilter {
    public var displayName: String {
        return "Pitched"
    }

    public var filterType: FilterType {
        return .Pitched
    }
}
