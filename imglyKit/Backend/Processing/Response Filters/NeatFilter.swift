//
//  NeatFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYNeatFilter) public class NeatFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Neat")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension NeatFilter: EffectFilter {
    public var displayName: String {
        return "Neat"
    }

    public var filterType: FilterType {
        return .Neat
    }
}
