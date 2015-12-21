//
//  IMGLYCreamyFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCreamyFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Creamy")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYCreamyFilter: EffectFilterType {
    public var displayName: String {
        return "Creamy"
    }
    
    public var filterType: IMGLYFilterType {
        return .Creamy
    }
}