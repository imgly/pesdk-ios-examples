//
//  LucidFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYLucidFilter) public class LucidFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Lucid")
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

extension LucidFilter: EffectFilter {
    /// The name that is used within the UI
    public var displayName: String {
        return "Lucid"
    }

    public var filterType: FilterType {
        return .Lucid
    }
}
