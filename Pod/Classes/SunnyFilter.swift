//
//  SunnyFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYSunnyFilter) public class SunnyFilter: ResponseFilter {
    init() {
        super.init(responseName: "Sunny")
        self.displayName = "Sunny"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Sunny
        }
    }
}
