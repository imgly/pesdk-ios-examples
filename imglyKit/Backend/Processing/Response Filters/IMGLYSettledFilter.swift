//
//  IMGLYSettledFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSettledFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Settled")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYSettledFilter: EffectFilterType {
    public var displayName: String {
        return "Settled"
    }
    
    public var filterType: IMGLYFilterType {
        return .Settled
    }
}