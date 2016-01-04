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

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension FoodFilter: EffectFilter {
    public var displayName: String {
        return "Food"
    }

    public var filterType: FilterType {
        return .Food
    }
}
