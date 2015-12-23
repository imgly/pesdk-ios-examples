//
//  ElderFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYElderFilter) public class ElderFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Elder")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ElderFilter: EffectFilter {
    public var displayName: String {
        return "Elder"
    }

    public var filterType: FilterType {
        return .Elder
    }
}
