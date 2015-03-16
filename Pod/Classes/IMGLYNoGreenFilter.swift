//
// IMGLYNoGreenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYNoGreenFilter: IMGLYResponseFilter {
    override init() {
        super.init()         
        self.responseName = "NoGreen"
        self.displayName = "no green"
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.NoGreen
        }
    }
}
