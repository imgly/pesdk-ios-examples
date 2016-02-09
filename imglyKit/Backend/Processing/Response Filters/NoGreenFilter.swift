//
// NoGreenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYNoGreenFilter) public class NoGreenFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "NoGreen")
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

extension NoGreenFilter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "No Green"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .NoGreen
    }
}
