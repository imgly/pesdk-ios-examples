//
//  IMGLYTwilightFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYTwilightFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Twilight")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYTwilightFilter: EffectFilterType {
    public var displayName: String {
        return "Twilight"
    }
    
    public var filterType: IMGLYFilterType {
        return .Twilight
    }
}