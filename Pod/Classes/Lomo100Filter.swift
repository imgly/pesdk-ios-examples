//
//  Lomo100Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYLomo100Filter) public class Lomo100Filter: ResponseFilter {
    init() {
        super.init(responseName: "Lomo100")
        self.displayName = "Lomo 100"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:FilterType {
        get {
            return FilterType.Lomo100
        }
    }
}