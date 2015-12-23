//
//  IMGLYCelsiusFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCelsiusFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Celsius")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYCelsiusFilter: EffectFilterType {
    public var displayName: String {
        return "Celsius"
    }

    public var filterType: IMGLYFilterType {
        return .Celsius
    }
}
