//
//  IMGLYSteelFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSteelFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Steel")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYSteelFilter: EffectFilterType {
    public var displayName: String {
        return "Steel"
    }

    public var filterType: IMGLYFilterType {
        return .Steel
    }
}
