//
//  Lomo100Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**

 */
@objc(IMGLYLomo100Filter) public class Lomo100Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "Lomo100")
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

extension Lomo100Filter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "Lomo 100"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .Lomo100
    }
}
