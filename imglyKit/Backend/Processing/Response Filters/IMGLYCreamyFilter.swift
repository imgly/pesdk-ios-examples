//
//  IMGLYCreamyFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCreamyFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Creamy")
        self.imgly_displayName = "Creamy"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Creamy
        }
    }
}
