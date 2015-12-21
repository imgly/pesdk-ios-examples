//
//  IMGLYPola669Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPola669Filter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Pola669")
        self.imgly_displayName = "669"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Pola669
    }
}
