//
//  FixieFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class FixieFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Fixie")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension FixieFilter: EffectFilter {
    public var displayName: String {
        return "Fixie"
    }

    public var filterType: FilterType {
        return .Fixie
    }
}
