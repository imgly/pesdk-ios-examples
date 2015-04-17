//
//  BWFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYBWFilter) public class BWFilter: ResponseFilter {
    init() {
        super.init(responseName: "BW")
        self.displayName = "BW"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.BW
        }
    }
}
