//
//  IMGLYTexasFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYTexasFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Texas")
        self.imgly_displayName = "Texas"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Texas
    }
}
