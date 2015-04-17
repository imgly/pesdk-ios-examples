//
//  Mono3200Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYMono3200Filter) public class Mono3200Filter: ResponseFilter {
    init() {
        super.init(responseName: "Mono3200")
        self.displayName = "Mono3200"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Mono3200
        }
    }
}