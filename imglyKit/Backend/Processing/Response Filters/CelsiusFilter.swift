//
//  CelsiusFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYCelsiusFilter) public class CelsiusFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Celsius")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CelsiusFilter: EffectFilter {
    public var displayName: String {
        return "Celsius"
    }

    public var filterType: FilterType {
        return .Celsius
    }
}
