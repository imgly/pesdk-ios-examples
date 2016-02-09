//
//  K6Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYK6Filter) public class K6Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "K6")
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

extension K6Filter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "K6"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .K6
    }
}
