//
//  SinFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYSinFilter) public class SinFilter: ResponseFilter {
    init() {
        super.init(responseName: "Sin")
        self.displayName = "Sin"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Sin
        }
    }
}
