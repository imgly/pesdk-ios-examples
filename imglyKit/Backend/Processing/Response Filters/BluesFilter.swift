//
//  BluesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class BluesFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Blues")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension BluesFilter: EffectFilter {
    public var displayName: String {
        return "Blues"
    }

    public var filterType: FilterType {
        return .Blues
    }
}
