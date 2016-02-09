//
//  FoodFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYFoodFilter) public class FoodFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Food")
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

extension FoodFilter: EffectFilter {
    /// The name that is used within the UI.
    public var displayName: String {
        return "Food"
    }

    /// The filter type.
    public var filterType: FilterType {
        return .Food
    }
}
