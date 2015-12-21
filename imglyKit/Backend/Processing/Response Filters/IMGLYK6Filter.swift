//
//  IMGLYK6Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYK6Filter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "K6")
        self.imgly_displayName = "K6"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .K6
    }
}
