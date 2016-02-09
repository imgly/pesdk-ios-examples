//
//  LeninFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYLeninFilter) public class LeninFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Lenin")
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

extension LeninFilter: EffectFilter {
    /// The name that is used within the UI
    public var displayName: String {
        return "Lenin"
    }

    public var filterType: FilterType {
        return .Lenin
    }
}
