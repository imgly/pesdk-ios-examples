//
//  IMGLYPitchedFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPitchedFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Pitched")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYPitchedFilter: EffectFilterType {
    public var displayName: String {
        return "Pitched"
    }

    public var filterType: IMGLYFilterType {
        return .Pitched
    }
}
