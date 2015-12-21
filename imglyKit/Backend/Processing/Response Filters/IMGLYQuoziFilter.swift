//
//  IMGLYQuoziFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYQuoziFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Quozi")
        self.imgly_displayName = "Quozi"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Quozi
    }
}
