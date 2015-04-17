//
//  LithoFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYLithoFilter) public class LithoFilter: ResponseFilter {
    init() {
        super.init(responseName: "Litho")
        self.displayName = "Litho"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Litho
        }
    }
}