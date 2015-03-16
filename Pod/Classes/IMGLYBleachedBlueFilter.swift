//
//  IMGLYBleachedBlueFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYBleachedBlueFilter: IMGLYResponseFilter {
    public override init() {
        super.init()
        self.responseName = "BleachedBlue"
        self.displayName = "b-blue"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.BleachedBlue
        }
    }
}