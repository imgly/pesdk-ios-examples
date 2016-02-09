//
//  K1Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYK1Filter) public class K1Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "K1")
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

extension K1Filter: EffectFilter {
    public var displayName: String {
        return "K1"
    }

    public var filterType: FilterType {
        return .K1
    }
}
