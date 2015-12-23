//
//  IMGLYSinFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSinFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Sin")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYSinFilter: EffectFilterType {
    public var displayName: String {
        return "Sin"
    }

    public var filterType: IMGLYFilterType {
        return .Sin
    }
}
