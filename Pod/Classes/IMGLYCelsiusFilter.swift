//
//  IMGLYCelsiusFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCelsiusFilter: IMGLYResponseFilter {
    override public init() {
        super.init()
        self.responseName = "Celsius"
        self.displayName = "celsius"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Celsius
        }
    }
}
