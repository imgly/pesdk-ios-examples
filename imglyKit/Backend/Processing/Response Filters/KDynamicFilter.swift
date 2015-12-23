//
//  KDynamicFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYKDynamicFilter) public class KDynamicFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "KDynamic")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension KDynamicFilter: EffectFilter {
    public var displayName: String {
        return "Dynamic"
    }

    public var filterType: FilterType {
        return .KDynamic
    }
}
