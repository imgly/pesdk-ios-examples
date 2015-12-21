//
//  IMGLYSeventiesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSeventiesFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Seventies")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYSeventiesFilter: EffectFilterType {
    public var displayName: String {
        return "70s"
    }
    
    public var filterType: IMGLYFilterType {
        return .Seventies
    }
}