//
//  IMGLYFrontFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYFrontFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Front")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYFrontFilter: EffectFilterType {
    public var displayName: String {
        return "Front"
    }
    
    public var filterType: IMGLYFilterType {
        return .Front
    }
}