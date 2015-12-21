//
//  IMGLYK2Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYK2Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "K2")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYK2Filter: EffectFilterType {
    public var displayName: String {
        return "K2"
    }
    
    public var filterType: IMGLYFilterType {
        return .K2
    }
}