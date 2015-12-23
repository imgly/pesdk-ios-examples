//
//  IMGLYFridgeFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYFridgeFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Fridge")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFridgeFilter: EffectFilterType {
    public var displayName: String {
        return "Fridge"
    }

    public var filterType: IMGLYFilterType {
        return .Fridge
    }
}
