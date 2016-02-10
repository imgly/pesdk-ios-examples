//
//  AD1920Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**

 */
@objc(IMGLYAD1920Filter) public class AD1920Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "AD1920")
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

extension AD1920Filter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "AD1920"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .AD1920
    }
}
