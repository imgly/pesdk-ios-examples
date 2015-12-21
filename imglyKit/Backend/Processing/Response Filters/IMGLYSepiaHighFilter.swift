//
//  IMGLYSepiaHighFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSepiaHighFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "SepiaHigh")
        self.imgly_displayName = "Sepia High"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.SepiaHigh
        }
    }
}
