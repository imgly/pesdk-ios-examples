//
//  K2Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
 :nodoc:
 */
@objc(IMGLYK2Filter) public class K2Filter: ResponseFilter {
    /**
     :nodoc:
     */
    required public init() {
        super.init(responseName: "K2")
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

extension K2Filter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "K2"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .K2
    }
}
