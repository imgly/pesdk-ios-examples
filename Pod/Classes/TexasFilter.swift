//
//  TexasFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYTexasFilter) public class TexasFilter: ResponseFilter {
    init() {
        super.init(responseName: "Texas")
        self.displayName = "Texas"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Texas
        }
    }
}
