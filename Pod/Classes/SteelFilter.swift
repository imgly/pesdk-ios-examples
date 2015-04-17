//
//  SteelFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYSteelFilter) public class SteelFilter: ResponseFilter {
    init() {
        super.init(responseName: "Steel")
        self.displayName = "Steel"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Steel
        }
    }
}