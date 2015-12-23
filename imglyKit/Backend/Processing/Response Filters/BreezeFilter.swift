//
//  BreezeFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class BreezeFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Breeze")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension BreezeFilter: EffectFilter {
    public var displayName: String {
        return "Breeze"
    }

    public var filterType: FilterType {
        return .Breeze
    }
}
