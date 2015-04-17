//
//  AD1920Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYAD1920Filter) public class AD1920Filter: ResponseFilter {
    init() {
        super.init(responseName: "AD1920")
        self.displayName = "AD1920"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.AD1920
        }
    }
}
