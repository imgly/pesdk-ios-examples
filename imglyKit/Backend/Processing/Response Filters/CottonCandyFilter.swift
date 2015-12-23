//
//  CottonCandyFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class CottonCandyFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "CottonCandy")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CottonCandyFilter: EffectFilter {
    public var displayName: String {
        return "Candy"
    }

    public var filterType: FilterType {
        return .CottonCandy
    }
}
