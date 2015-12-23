//
//  BWFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class BWFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "BW")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension BWFilter: EffectFilter {
    public var displayName: String {
        return "BW"
    }

    public var filterType: FilterType {
        return .BW
    }
}
