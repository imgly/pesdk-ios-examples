//
//  GlamFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class GlamFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Glam")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension GlamFilter: EffectFilter {
    public var displayName: String {
        return "Glam"
    }

    public var filterType: FilterType {
        return .Glam
    }
}
