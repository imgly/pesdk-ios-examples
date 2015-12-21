//
// IMGLYNoGreenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYNoGreenFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "NoGreen")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYNoGreenFilter: EffectFilterType {
    public var displayName: String {
        return "No Green"
    }
    
    public var filterType: IMGLYFilterType {
        return .NoGreen
    }
}