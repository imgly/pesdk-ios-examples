//
//  BlueShadowsFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYBlueShadowsFilter) public class BlueShadowsFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "BlueShadows")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension BlueShadowsFilter: EffectFilter {
    public var displayName: String {
        return "Blue Shade"
    }

    public var filterType: FilterType {
        return .BlueShadows
    }
}
