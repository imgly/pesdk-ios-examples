//
//  BleachedFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYBleachedFilter) public class BleachedFilter: ResponseFilter {
    init() {
        super.init(responseName: "Bleached")
        self.displayName = "Bleached"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Bleached
        }
    }
}