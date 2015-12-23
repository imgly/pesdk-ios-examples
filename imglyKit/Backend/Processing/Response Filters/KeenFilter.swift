//
//  KeenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class KeenFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Keen")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension KeenFilter: EffectFilter {
    public var displayName: String {
        return "Keen"
    }

    public var filterType: FilterType {
        return .Keen
    }
}
