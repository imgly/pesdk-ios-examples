//
//  BlueShadowsFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**

 */
@objc(IMGLYBlueShadowsFilter) public class BlueShadowsFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "BlueShadows")
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

extension BlueShadowsFilter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "Blue Shade"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .BlueShadows
    }
}
