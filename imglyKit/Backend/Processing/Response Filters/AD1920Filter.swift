//
//  AD1920Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class AD1920Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "AD1920")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension AD1920Filter: EffectFilter {
    public var displayName: String {
        return "AD1920"
    }

    public var filterType: FilterType {
        return .AD1920
    }
}
