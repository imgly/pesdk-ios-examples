//
//  IMGLYPolaSXFIlter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPolaSXFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "PolaSX")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYPolaSXFilter: EffectFilterType {
    public var displayName: String {
        return "SX"
    }
    
    public var filterType: IMGLYFilterType {
        return .PolaSX
    }
}