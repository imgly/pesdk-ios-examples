//
//  CoolFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
 :nodoc:
 */
@objc(IMGLYCoolFilter) public class CoolFilter: ResponseFilter {
    /**
     :nodoc:
     */
    required public init() {
        super.init(responseName: "Cool")
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

extension CoolFilter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "Cool"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .Cool
    }
}
