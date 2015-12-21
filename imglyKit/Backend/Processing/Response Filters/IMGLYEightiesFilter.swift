//
//  IMGLYEightiesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYEightiesFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Eighties")
        self.imgly_displayName = "80s"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Eighties
    }
}
