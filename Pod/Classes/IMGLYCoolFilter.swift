//
//  IMGLYCoolFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCoolFilter: IMGLYResponseFilter {
    override public init() {
        super.init()
        self.responseName = "Cool"
        self.displayName = "cool"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Cool
        }
    }
}