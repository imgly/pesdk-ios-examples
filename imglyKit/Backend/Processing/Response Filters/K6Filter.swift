//
//  K6Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class K6Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "K6")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension K6Filter: EffectFilter {
    public var displayName: String {
        return "K6"
    }

    public var filterType: FilterType {
        return .K6
    }
}
