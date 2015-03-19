//
//  IMGLYAD1920Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYAD1920Filter: IMGLYResponseFilter {
    override init() {
        super.init()
        self.responseName = "AD1920"
        self.displayName = "AD1920"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.AD1920
        }
    }
}
