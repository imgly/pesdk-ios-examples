//
//  IMGLYColorfulilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYColorfulFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Colorful")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYColorfulFilter: EffectFilterType {
    public var displayName: String {
        return "Colorful"
    }
    
    public var filterType: IMGLYFilterType {
        return .Colorful
    }
}