//
//  IMGLYSteelFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSteelFilter: IMGLYResponseFilter {
    public override init() {
        super.init()
        self.responseName = "Steel"
        self.displayName = "steel"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Steel
        }
    }
}