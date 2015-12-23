//
// NoGreenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class NoGreenFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "NoGreen")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension NoGreenFilter: EffectFilter {
    public var displayName: String {
        return "No Green"
    }

    public var filterType: FilterType {
        return .NoGreen
    }
}
