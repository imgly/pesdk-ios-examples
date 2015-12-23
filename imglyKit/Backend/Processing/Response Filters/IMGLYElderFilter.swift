//
//  IMGLYElderFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYElderFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Elder")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYElderFilter: EffectFilterType {
    public var displayName: String {
        return "Elder"
    }

    public var filterType: IMGLYFilterType {
        return .Elder
    }
}
