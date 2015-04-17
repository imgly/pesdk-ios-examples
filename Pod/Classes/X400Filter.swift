//
//  X400Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYX400Filter) public class X400Filter: ResponseFilter {
    init() {
        super.init(responseName: "X400")
        self.displayName = "X400"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.X400
        }
    }
}
