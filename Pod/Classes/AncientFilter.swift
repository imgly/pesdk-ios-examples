//
//  AncientFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYAncientFilter) public class AncientFilter: ResponseFilter {
    init() {
        super.init(responseName: "Ancient")
        self.displayName = "Ancient"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Ancient
        }
    }
}