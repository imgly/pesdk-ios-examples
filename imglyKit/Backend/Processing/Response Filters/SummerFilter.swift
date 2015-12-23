//
//  SummerFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class SummerFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Summer")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SummerFilter: EffectFilter {
    public var displayName: String {
        return "Summer"
    }

    public var filterType: FilterType {
        return .Summer
    }
}
