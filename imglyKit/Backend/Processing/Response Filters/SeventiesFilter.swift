//
//  SeventiesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**

 */
@objc(IMGLYSeventiesFilter) public class SeventiesFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Seventies")
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

extension SeventiesFilter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "70s"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .Seventies
    }
}
