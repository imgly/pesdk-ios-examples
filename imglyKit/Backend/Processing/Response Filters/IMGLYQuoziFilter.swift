//
//  IMGLYQuoziFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYQuoziFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Quozi")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYQuoziFilter: EffectFilterType {
    public var displayName: String {
        return "Quozi"
    }
    
    public var filterType: IMGLYFilterType {
        return .Quozi
    }
}