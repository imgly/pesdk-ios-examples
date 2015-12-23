//
//  LithoFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class LithoFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Litho")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension LithoFilter: EffectFilter {
    public var displayName: String {
        return "Litho"
    }

    public var filterType: FilterType {
        return .Litho
    }
}
