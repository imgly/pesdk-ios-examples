//
//  WinterFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class WinterFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Winter")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension WinterFilter: EffectFilter {
    public var displayName: String {
        return "Winter"
    }

    public var filterType: FilterType {
        return .Winter
    }
}
