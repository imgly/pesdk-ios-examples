//
//  A15Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYA15Filter) public class A15Filter: ResponseFilter {
    init() {
        super.init(responseName: "A15")
        self.displayName = "A15"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.A15
        }
    }
}
