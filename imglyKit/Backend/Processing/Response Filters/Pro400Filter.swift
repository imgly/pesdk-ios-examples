//
//  Pro400Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class Pro400Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "Pro400")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension Pro400Filter: EffectFilter {
    public var displayName: String {
        return "Pro 400"
    }

    public var filterType: FilterType {
        return .Pro400
    }
}
