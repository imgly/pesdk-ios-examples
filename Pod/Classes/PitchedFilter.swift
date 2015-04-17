//
//  PitchedFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYPitchedFilter) public class PitchedFilter: ResponseFilter {
    init() {
        super.init(responseName: "Pitched")
        self.displayName = "Pitched"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Pitched
        }
    }
}