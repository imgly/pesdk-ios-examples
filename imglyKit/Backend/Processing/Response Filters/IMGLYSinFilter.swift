//
//  IMGLYSinFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSinFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Sin")
        self.imgly_displayName = "Sin"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Sin
        }
    }
}
