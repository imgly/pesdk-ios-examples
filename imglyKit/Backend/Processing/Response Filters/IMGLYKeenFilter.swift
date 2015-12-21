//
//  IMGLYKeenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYKeenFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Keen")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYKeenFilter: EffectFilterType {
    public var displayName: String {
        return "Keen"
    }
    
    public var filterType: IMGLYFilterType {
        return .Keen
    }
}