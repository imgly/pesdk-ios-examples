//
//  IMGLYSunsetFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSunsetFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Sunset")
        self.imgly_displayName = "Sunset"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Sunset
    }
}
