//
//  BleachedFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYBleachedFilter) public class BleachedFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Bleached")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension BleachedFilter: EffectFilter {
    public var displayName: String {
        return "Bleached"
    }

    public var filterType: FilterType {
        return .Bleached
    }
}
