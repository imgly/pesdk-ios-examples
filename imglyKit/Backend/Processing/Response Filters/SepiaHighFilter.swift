//
//  SepiaHighFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class SepiaHighFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "SepiaHigh")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SepiaHighFilter: EffectFilter {
    public var displayName: String {
        return "Sepia High"
    }

    public var filterType: FilterType {
        return .SepiaHigh
    }
}
