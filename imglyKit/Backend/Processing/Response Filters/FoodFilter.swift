//
//  IMGLYFoodFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYFoodFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Food")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFoodFilter: EffectFilterType {
    public var displayName: String {
        return "Food"
    }

    public var filterType: IMGLYFilterType {
        return .Food
    }
}
