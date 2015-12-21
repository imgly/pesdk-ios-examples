//
//  IMGLYBWFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYBWFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "BW")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYBWFilter: EffectFilterType {
    public var displayName: String {
        return "BW"
    }
    
    public var filterType: IMGLYFilterType {
        return .BW
    }
}