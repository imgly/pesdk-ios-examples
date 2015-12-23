//
//  QuoziFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class QuoziFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Quozi")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension QuoziFilter: EffectFilter {
    public var displayName: String {
        return "Quozi"
    }

    public var filterType: FilterType {
        return .Quozi
    }
}
