//
//  K2Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYK2Filter) public class K2Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "K2")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension K2Filter: EffectFilter {
    public var displayName: String {
        return "K2"
    }

    public var filterType: FilterType {
        return .K2
    }
}
