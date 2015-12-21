//
//  IMGLYKDynamicFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYKDynamicFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "KDynamic")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYKDynamicFilter: EffectFilterType {
    public var displayName: String {
        return "Dynamic"
    }
    
    public var filterType: IMGLYFilterType {
        return .KDynamic
    }
}