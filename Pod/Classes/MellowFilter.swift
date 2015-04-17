//
//  MellowFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYMellowFilter) public class MellowFilter: ResponseFilter {
    init() {
        super.init(responseName: "Mellow")
        self.displayName = "Mellow"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Mellow
        }
    }
}
