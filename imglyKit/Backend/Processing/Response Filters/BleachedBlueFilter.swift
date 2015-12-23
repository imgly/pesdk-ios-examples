//
//  IMGLYBleachedBlueFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYBleachedBlueFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "BleachedBlue")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYBleachedBlueFilter: EffectFilterType {
    public var displayName: String {
        return "B-Blue"
    }

    public var filterType: IMGLYFilterType {
        return .BleachedBlue
    }
}
