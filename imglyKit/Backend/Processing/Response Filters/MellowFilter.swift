//
//  IMGLYMellowFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYMellowFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Mellow")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYMellowFilter: EffectFilterType {
    public var displayName: String {
        return "Mellow"
    }

    public var filterType: IMGLYFilterType {
        return .Mellow
    }
}
