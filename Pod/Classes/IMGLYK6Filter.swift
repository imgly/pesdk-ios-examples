//
//  IMGLYK6Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYK6Filter: IMGLYResponseFilter {
    override init() {
        super.init()
        self.responseName = "K6"
        self.displayName = "K6"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.K6
        }
    }
}
