//
//  IMGLYK6Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYK6Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "K6")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYK6Filter: EffectFilterType {
    public var displayName: String {
        return "K6"
    }
    
    public var filterType: IMGLYFilterType {
        return .K6
    }
}