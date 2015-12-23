//
//  SteelFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYSteelFilter) public class SteelFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Steel")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SteelFilter: EffectFilter {
    public var displayName: String {
        return "Steel"
    }

    public var filterType: FilterType {
        return .Steel
    }
}
