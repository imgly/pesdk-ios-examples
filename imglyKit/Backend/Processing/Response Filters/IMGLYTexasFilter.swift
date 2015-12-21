//
//  IMGLYTexasFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYTexasFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Texas")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYTexasFilter: EffectFilterType {
    public var displayName: String {
        return "Texas"
    }
    
    public var filterType: IMGLYFilterType {
        return .Texas
    }
}