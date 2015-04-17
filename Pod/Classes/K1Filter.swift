//
//  K1Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYK1Filter) public class K1Filter: ResponseFilter {
    init() {
        super.init(responseName: "K1")
        self.displayName = "K1"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.K1
        }
    }
}
