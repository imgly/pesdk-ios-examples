//
//  IMGLYSepiaHighFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSepiaHighFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "SepiaHigh")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYSepiaHighFilter: EffectFilterType {
    public var displayName: String {
        return "Sepia High"
    }

    public var filterType: IMGLYFilterType {
        return .SepiaHigh
    }
}
