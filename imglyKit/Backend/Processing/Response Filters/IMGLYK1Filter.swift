//
//  IMGLYK1Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYK1Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "K1")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYK1Filter: EffectFilterType {
    public var displayName: String {
        return "K1"
    }
    
    public var filterType: IMGLYFilterType {
        return .K1
    }
}