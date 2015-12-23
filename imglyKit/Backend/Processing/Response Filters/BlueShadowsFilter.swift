//
//  IMGLYBlueShadowsFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYBlueShadowsFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "BlueShadows")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYBlueShadowsFilter: EffectFilterType {
    public var displayName: String {
        return "Blue Shade"
    }

    public var filterType: IMGLYFilterType {
        return .BlueShadows
    }
}
