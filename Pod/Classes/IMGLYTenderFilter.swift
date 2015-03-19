//
//  IMGLYTenderFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYTenderFilter: IMGLYResponseFilter {
    override init() {
        super.init()
        self.responseName = "Tender"
        self.displayName = "Tender"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Tender
        }
    }
}