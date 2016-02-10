//
//  Pro400Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**

 */
@objc(IMGLYPro400Filter) public class Pro400Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "Pro400")
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

extension Pro400Filter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "Pro 400"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .Pro400
    }
}
