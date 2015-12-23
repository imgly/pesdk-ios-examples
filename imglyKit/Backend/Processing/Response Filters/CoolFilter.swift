//
//  CoolFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class CoolFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Cool")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CoolFilter: EffectFilter {
    public var displayName: String {
        return "Cool"
    }

    public var filterType: FilterType {
        return .Cool
    }
}
