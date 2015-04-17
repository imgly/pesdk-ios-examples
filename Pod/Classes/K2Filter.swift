//
//  K2Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYK2Filter) public class K2Filter: ResponseFilter {
    init() {
        super.init(responseName: "K2")
        self.displayName = "K2"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.K2
        }
    }
}
