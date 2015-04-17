//
//  QuoziFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYQuoziFilter) public class QuoziFilter: ResponseFilter {
    init() {
        super.init(responseName: "Quozi")
        self.displayName = "Quozi"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Quozi
        }
    }
}
