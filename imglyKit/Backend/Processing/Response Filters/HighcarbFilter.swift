//
//  HighcarbFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYHighcarbFilter) public class HighcarbFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Highcarb")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension HighcarbFilter: EffectFilter {
    public var displayName: String {
        return "Carb"
    }

    public var filterType: FilterType {
        return .Highcarb
    }
}
