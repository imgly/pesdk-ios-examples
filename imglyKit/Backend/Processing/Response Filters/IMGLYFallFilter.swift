//
//  IMGLYFallFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYFallFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Fall")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFallFilter: EffectFilterType {
    public var displayName: String {
        return "Fall"
    }
    
    public var filterType: IMGLYFilterType {
        return .Fall
    }
}