//
//  IMGLYCottonCandyFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCottonCandyFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "CottonCandy")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYCottonCandyFilter: EffectFilterType {
    public var displayName: String {
        return "Candy"
    }
    
    public var filterType: IMGLYFilterType {
        return .CottonCandy
    }
}