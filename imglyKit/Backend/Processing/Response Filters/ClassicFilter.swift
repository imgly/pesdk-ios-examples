//
//  IMGLYClassicFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYClassicFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Classic")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYClassicFilter: EffectFilterType {
    public var displayName: String {
        return "Classic"
    }

    public var filterType: IMGLYFilterType {
        return .Classic
    }
}
