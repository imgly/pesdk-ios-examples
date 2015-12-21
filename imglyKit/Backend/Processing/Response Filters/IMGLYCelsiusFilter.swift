//
//  IMGLYCelsiusFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYCelsiusFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Celsius")
        self.imgly_displayName = "Celsius"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Celsius
    }
}
