//
//  IMGLYAncientFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYAncientFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Ancient")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYAncientFilter: EffectFilterType {
    public var displayName: String {
        return "Ancient"
    }
    
    public var filterType: IMGLYFilterType {
        return .Ancient
    }
}