//
//  IMGLYCoolFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCoolFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Cool")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYCoolFilter: EffectFilterType {
    public var displayName: String {
        return "Cool"
    }
    
    public var filterType: IMGLYFilterType {
        return .Cool
    }
}