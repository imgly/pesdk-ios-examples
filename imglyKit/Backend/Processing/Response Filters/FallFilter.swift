//
//  FallFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class FallFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Fall")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension FallFilter: EffectFilter {
    public var displayName: String {
        return "Fall"
    }

    public var filterType: FilterType {
        return .Fall
    }
}
