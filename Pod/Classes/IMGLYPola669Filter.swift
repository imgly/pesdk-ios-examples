//
//  IMGLYPola669Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPola669Filter: IMGLYResponseFilter {
    override public init() {
        super.init()
        self.responseName = "Pola669"
        self.displayName = "669"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Pola669
        }
    }
}
