//
//  IMGLYAD1920Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYAD1920Filter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "AD1920")
        self.imgly_displayName = "AD1920"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .AD1920
    }
}
