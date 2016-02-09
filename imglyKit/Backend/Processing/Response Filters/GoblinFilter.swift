//
//  GoblinFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYGoblinFilter) public class GoblinFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Goblin")
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

extension GoblinFilter: EffectFilter {
    /// The name that is used within the UI
    public var displayName: String {
        return "Goblin"
    }

    public var filterType: FilterType {
        return .Goblin
    }
}
