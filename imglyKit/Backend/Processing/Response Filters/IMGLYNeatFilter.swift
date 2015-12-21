//
//  IMGLYNeatFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYNeatFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Neat")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYNeatFilter: EffectFilterType {
    public var displayName: String {
        return "Neat"
    }
    
    public var filterType: IMGLYFilterType {
        return .Neat
    }
}