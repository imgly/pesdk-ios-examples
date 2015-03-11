//
//  IMGLYFoodFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYFoodFilter: IMGLYResponseFilter {
    override public init() {
        super.init()
        self.responseName = "Food"
        self.displayName = "food"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Food
        }
    }
}
