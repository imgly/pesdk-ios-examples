//
//  FridgeFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class FridgeFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Fridge")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension FridgeFilter: EffectFilter {
    public var displayName: String {
        return "Fridge"
    }

    public var filterType: FilterType {
        return .Fridge
    }
}
