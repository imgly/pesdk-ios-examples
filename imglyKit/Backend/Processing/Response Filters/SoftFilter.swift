//
//  SoftFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYSoftFilter) public class SoftFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Soft")
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

extension SoftFilter: EffectFilter {
    public var displayName: String {
        return "Soft"
    }

    public var filterType: FilterType {
        return .Soft
    }
}
