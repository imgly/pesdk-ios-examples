//
//  LucidFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class LucidFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Lucid")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension LucidFilter: EffectFilter {
    public var displayName: String {
        return "Lucid"
    }

    public var filterType: FilterType {
        return .Lucid
    }
}
