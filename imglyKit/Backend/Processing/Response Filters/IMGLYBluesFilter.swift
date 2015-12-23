//
//  IMGLYBluesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYBluesFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Blues")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYBluesFilter: EffectFilterType {
    public var displayName: String {
        return "Blues"
    }

    public var filterType: IMGLYFilterType {
        return .Blues
    }
}
