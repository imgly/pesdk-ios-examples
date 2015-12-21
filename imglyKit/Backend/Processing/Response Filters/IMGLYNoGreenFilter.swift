//
// IMGLYNoGreenFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYNoGreenFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "NoGreen")
        self.imgly_displayName = "No Green"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .NoGreen
    }
}
