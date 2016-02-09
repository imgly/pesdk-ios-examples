//
//  TexasFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYTexasFilter) public class TexasFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Texas")
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

extension TexasFilter: EffectFilter {
    public var displayName: String {
        return "Texas"
    }

    public var filterType: FilterType {
        return .Texas
    }
}
