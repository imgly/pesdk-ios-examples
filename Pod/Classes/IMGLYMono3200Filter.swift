//
//  IMGLYMono3200Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYMono3200Filter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Mono3200")
        self.imgly_displayName = "Mono3200"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Mono3200
        }
    }
}