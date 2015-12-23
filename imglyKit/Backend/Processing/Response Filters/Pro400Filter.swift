//
//  IMGLYPro400Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPro400Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Pro400")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYPro400Filter: EffectFilterType {
    public var displayName: String {
        return "Pro 400"
    }

    public var filterType: IMGLYFilterType {
        return .Pro400
    }
}
