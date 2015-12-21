//
//  IMGLYPro400Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPro400Filter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Pro400")
        self.imgly_displayName = "Pro 400"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Pro400
    }
}
